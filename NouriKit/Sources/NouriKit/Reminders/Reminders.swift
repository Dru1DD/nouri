import Foundation
@preconcurrency import UserNotifications

public struct PlannedReminder: Hashable, Sendable {
    public var id: String
    public var title: String
    public var body: String
    public var fireDate: Date
    public var medicationID: UUID
    public var doseKey: String
    public var scheduledAt: Date
}

/// Decides which dose notifications should exist. Pure: no system frameworks involved.
///
/// One-shot notifications per dose (instead of repeating triggers) let us skip doses that
/// were already taken and honour weekdays/start/end dates. The plan is recomputed on launch,
/// foreground, time-zone/clock changes, and every notification action.
public enum ReminderPlanner {
    public static let dosePrefix = "dose."
    public static let snoozePrefix = "snooze."
    /// iOS keeps at most 64 pending requests per app; leave room for snoozes.
    public static let maxPending = 60
    public static let horizonDays = 14

    public static func plan(
        medications: [MedicationInfo],
        resolvedKeys: Set<String>,
        now: Date,
        calendar: Calendar,
        horizonDays: Int = horizonDays,
        maxCount: Int = maxPending
    ) -> [PlannedReminder] {
        let today = calendar.startOfDay(for: now)
        var result: [PlannedReminder] = []
        for offset in 0..<horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let doses = medications
                .flatMap { $0.occurrences(on: day, calendar: calendar) }
                .filter { $0.scheduledAt > now && !resolvedKeys.contains($0.key) }
                .sorted { ($0.scheduledAt, $0.key) < ($1.scheduledAt, $1.key) }
            for dose in doses {
                guard result.count < maxCount else { return result }
                result.append(reminder(for: dose, id: dosePrefix + dose.key, fireDate: dose.scheduledAt))
            }
        }
        return result
    }

    public static func snooze(_ dose: DoseOccurrence, now: Date, minutes: Int = 10) -> PlannedReminder {
        reminder(for: dose, id: snoozePrefix + dose.key, fireDate: now.addingTimeInterval(TimeInterval(minutes * 60)))
    }

    static func reminder(for dose: DoseOccurrence, id: String, fireDate: Date) -> PlannedReminder {
        PlannedReminder(id: id, title: "💊 Time to take \(dose.medicationName)", body: dose.dosageText,
                        fireDate: fireDate, medicationID: dose.medicationID, doseKey: dose.key,
                        scheduledAt: dose.scheduledAt)
    }
}

/// Thin seam over `UNUserNotificationCenter` so scheduling logic is testable.
public protocol NotificationClient: Sendable {
    func requestAuthorization() async -> Bool
    func pendingIDs() async -> [String]
    func add(_ reminder: PlannedReminder) async
    func remove(ids: [String]) async
}

@MainActor
public final class ReminderScheduler {
    public let client: NotificationClient

    public init(client: NotificationClient) {
        self.client = client
    }

    /// Makes pending dose notifications match `plan` exactly. Safe to call any number of times:
    /// identifiers are deterministic and re-adding an identifier replaces the old request.
    public func apply(_ plan: [PlannedReminder]) async {
        let desired = Set(plan.map(\.id))
        let stale = await client.pendingIDs().filter { $0.hasPrefix(ReminderPlanner.dosePrefix) && !desired.contains($0) }
        await client.remove(ids: stale)
        for reminder in plan { await client.add(reminder) }
    }

    public func snooze(_ dose: DoseOccurrence, now: Date, minutes: Int = 10) async {
        await client.add(ReminderPlanner.snooze(dose, now: now, minutes: minutes))
    }

    /// Called once a dose is resolved so nothing else fires for it.
    public func clear(doseKey: String) async {
        await client.remove(ids: [ReminderPlanner.dosePrefix + doseKey, ReminderPlanner.snoozePrefix + doseKey])
    }
}

/// In-memory client for tests and UI-test launches.
public actor InMemoryNotificationClient: NotificationClient {
    public private(set) var pending: [String: PlannedReminder] = [:]
    public private(set) var addCount = 0

    public init() {}

    public func requestAuthorization() async -> Bool { true }
    public func pendingIDs() async -> [String] { Array(pending.keys) }
    public func add(_ reminder: PlannedReminder) async {
        pending[reminder.id] = reminder
        addCount += 1
    }
    public func remove(ids: [String]) async {
        for id in ids { pending[id] = nil }
    }
}

public enum DoseNotification {
    public static let category = "DOSE_REMINDER"
    public static let takenAction = "DOSE_TAKEN"
    public static let snoozeAction = "DOSE_SNOOZE"
    public static let skipAction = "DOSE_SKIP"

    public static func registerCategory(on center: UNUserNotificationCenter = .current()) {
        let category = UNNotificationCategory(
            identifier: category,
            actions: [
                UNNotificationAction(identifier: takenAction, title: "Taken", options: []),
                UNNotificationAction(identifier: snoozeAction, title: "Snooze 10 min", options: []),
                UNNotificationAction(identifier: skipAction, title: "Skip", options: [.destructive]),
            ],
            intentIdentifiers: []
        )
        center.setNotificationCategories([category])
    }

    public struct Payload: Sendable {
        public var medicationID: UUID
        public var doseKey: String
        public var scheduledAt: Date
    }

    static func userInfo(for r: PlannedReminder) -> [String: Any] {
        ["medicationID": r.medicationID.uuidString, "doseKey": r.doseKey, "scheduledAt": r.scheduledAt.timeIntervalSince1970]
    }

    public static func payload(from userInfo: [AnyHashable: Any]) -> Payload? {
        guard let idString = userInfo["medicationID"] as? String, let id = UUID(uuidString: idString),
              let key = userInfo["doseKey"] as? String,
              let ts = userInfo["scheduledAt"] as? TimeInterval else { return nil }
        return Payload(medicationID: id, doseKey: key, scheduledAt: Date(timeIntervalSince1970: ts))
    }
}

public struct SystemNotificationClient: NotificationClient {
    public init() {}

    public func requestAuthorization() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    public func pendingIDs() async -> [String] {
        await UNUserNotificationCenter.current().pendingNotificationRequests().map(\.identifier)
    }

    public func add(_ reminder: PlannedReminder) async {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default
        content.categoryIdentifier = DoseNotification.category
        content.threadIdentifier = "medications"
        content.userInfo = DoseNotification.userInfo(for: reminder)
        // Floating wall-clock components (no time zone): matches the "local time" schedule semantics.
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminder.fireDate)
        let request = UNNotificationRequest(
            identifier: reminder.id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    public func remove(ids: [String]) async {
        guard !ids.isEmpty else { return }
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        center.removeDeliveredNotifications(withIdentifiers: ids)
    }
}
