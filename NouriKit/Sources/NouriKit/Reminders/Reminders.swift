import Foundation
@preconcurrency import UserNotifications

public struct PlannedReminder: Hashable, Sendable {
    public var id: String
    public var title: String
    public var body: String
    public var fireDate: Date
    public var category: String
    public var threadIdentifier: String
    /// Dose fields; empty for hydration reminders.
    public var medicationID: UUID
    public var doseKey: String
    public var scheduledAt: Date

    public init(
        id: String,
        title: String,
        body: String,
        fireDate: Date,
        category: String,
        threadIdentifier: String,
        medicationID: UUID = UUID(),
        doseKey: String = "",
        scheduledAt: Date = .distantPast
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.fireDate = fireDate
        self.category = category
        self.threadIdentifier = threadIdentifier
        self.medicationID = medicationID
        self.doseKey = doseKey
        self.scheduledAt = scheduledAt
    }
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
        PlannedReminder(
            id: id,
            title: String(localized: "💊 Time to take \(dose.medicationName)", bundle: .module),
            body: dose.dosageText,
            fireDate: fireDate,
            category: DoseNotification.category,
            threadIdentifier: "medications",
            medicationID: dose.medicationID,
            doseKey: dose.key,
            scheduledAt: dose.scheduledAt
        )
    }
}

/// Interval + quiet-hours hydration reminders for the remainder of today (and tomorrow's
/// awake window if budget remains). Skips when the daily goal is already met.
public enum HydrationReminderPlanner {
    public static let prefix = "hydrate."

    public static func plan(
        enabled: Bool,
        intervalMinutes: Int,
        quietStartMinutes: Int,
        quietEndMinutes: Int,
        todayHydrationML: Double,
        goalML: Double,
        now: Date,
        calendar: Calendar,
        maxCount: Int,
        horizonDays: Int = 2
    ) -> [PlannedReminder] {
        guard enabled, maxCount > 0, intervalMinutes > 0, todayHydrationML < goalML else { return [] }

        let dayStart = calendar.startOfDay(for: now)
        var result: [PlannedReminder] = []
        for offset in 0..<horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: dayStart) else { continue }
            for fire in slots(on: day, intervalMinutes: intervalMinutes,
                              quietStartMinutes: quietStartMinutes, quietEndMinutes: quietEndMinutes,
                              calendar: calendar) where fire > now {
                guard result.count < maxCount else { return result }
                result.append(reminder(at: fire, calendar: calendar))
            }
        }
        return result
    }

    /// Fire times inside the awake window for `day`, aligned to the interval from awake start.
    public static func slots(
        on day: Date,
        intervalMinutes: Int,
        quietStartMinutes: Int,
        quietEndMinutes: Int,
        calendar: Calendar
    ) -> [Date] {
        guard let awake = awakeWindow(on: day, quietStartMinutes: quietStartMinutes,
                                      quietEndMinutes: quietEndMinutes, calendar: calendar) else { return [] }
        var times: [Date] = []
        var cursor = awake.start
        let step = TimeInterval(intervalMinutes * 60)
        while cursor < awake.end {
            times.append(cursor)
            cursor = cursor.addingTimeInterval(step)
        }
        return times
    }

    /// Awake window on a calendar day given overnight or same-day quiet hours.
    public static func awakeWindow(
        on day: Date,
        quietStartMinutes: Int,
        quietEndMinutes: Int,
        calendar: Calendar
    ) -> DateInterval? {
        let startOfDay = calendar.startOfDay(for: day)
        func at(_ minutes: Int) -> Date? {
            calendar.date(byAdding: .minute, value: minutes, to: startOfDay)
        }
        if quietStartMinutes == quietEndMinutes {
            // No quiet hours — whole day.
            guard let end = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return nil }
            return DateInterval(start: startOfDay, end: end)
        }
        if quietStartMinutes > quietEndMinutes {
            // Overnight quiet (e.g. 22:00–08:00) → awake quietEnd…quietStart.
            guard let start = at(quietEndMinutes), let end = at(quietStartMinutes), start < end else { return nil }
            return DateInterval(start: start, end: end)
        }
        // Same-day quiet (e.g. 12:00–14:00) → two awake segments; use morning + afternoon as one
        // continuous preference by taking start-of-day…quietStart and quietEnd…end-of-day is
        // awkward for interval slots. Prefer the longer evening-adjacent window after quiet ends.
        guard let start = at(quietEndMinutes),
              let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay),
              start < endOfDay else { return nil }
        return DateInterval(start: start, end: endOfDay)
    }

    public static func isInQuietHours(
        _ date: Date,
        quietStartMinutes: Int,
        quietEndMinutes: Int,
        calendar: Calendar
    ) -> Bool {
        if quietStartMinutes == quietEndMinutes { return false }
        let mins = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        if quietStartMinutes < quietEndMinutes {
            return mins >= quietStartMinutes && mins < quietEndMinutes
        }
        return mins >= quietStartMinutes || mins < quietEndMinutes
    }

    static func reminder(at fireDate: Date, calendar: Calendar) -> PlannedReminder {
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let id = String(format: "%@%04d%02d%02d.%02d%02d",
                        prefix,
                        comps.year ?? 0, comps.month ?? 0, comps.day ?? 0,
                        comps.hour ?? 0, comps.minute ?? 0)
        return PlannedReminder(
            id: id,
            title: String(localized: "💧 Time for a drink", bundle: .module),
            body: String(localized: "A quick sip keeps you on track.", bundle: .module),
            fireDate: fireDate,
            category: HydrationNotification.category,
            threadIdentifier: "hydration"
        )
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

    /// Makes pending dose + hydration notifications match `plan` exactly. Snoozes are never pruned.
    public func apply(_ plan: [PlannedReminder]) async {
        let desired = Set(plan.map(\.id))
        let pending = await client.pendingIDs()
        let stale = pending.filter { id in
            let managed = id.hasPrefix(ReminderPlanner.dosePrefix) || id.hasPrefix(HydrationReminderPlanner.prefix)
            return managed && !desired.contains(id)
        }
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

    public func clearAllManaged() async {
        let ids = await client.pendingIDs().filter {
            $0.hasPrefix(ReminderPlanner.dosePrefix)
                || $0.hasPrefix(ReminderPlanner.snoozePrefix)
                || $0.hasPrefix(HydrationReminderPlanner.prefix)
        }
        await client.remove(ids: ids)
    }
}

/// In-memory client for tests and UI-test launches.
public actor InMemoryNotificationClient: NotificationClient {
    public private(set) var pending: [String: PlannedReminder] = [:]
    public private(set) var addCount = 0
    public var authorizeResult = true

    public init() {}

    public func requestAuthorization() async -> Bool { authorizeResult }
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

    public static func registerCategories(on center: UNUserNotificationCenter = .current()) {
        center.setNotificationCategories([makeCategory(), HydrationNotification.makeCategory()])
    }

    public static func registerCategory(on center: UNUserNotificationCenter = .current()) {
        registerCategories(on: center)
    }

    static func makeCategory() -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category,
            actions: [
                UNNotificationAction(identifier: takenAction, title: String(localized: "Taken", bundle: .module), options: []),
                UNNotificationAction(identifier: snoozeAction, title: String(localized: "Snooze 10 min", bundle: .module), options: []),
                UNNotificationAction(identifier: skipAction, title: String(localized: "Skip", bundle: .module), options: [.destructive]),
            ],
            intentIdentifiers: []
        )
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
              let key = userInfo["doseKey"] as? String, !key.isEmpty,
              let ts = userInfo["scheduledAt"] as? TimeInterval else { return nil }
        return Payload(medicationID: id, doseKey: key, scheduledAt: Date(timeIntervalSince1970: ts))
    }
}

public enum HydrationNotification {
    public static let category = "HYDRATION_REMINDER"
    public static let add100 = "HYDRATE_100"
    public static let add250 = "HYDRATE_250"
    public static let add500 = "HYDRATE_500"

    public static func registerCategory(on center: UNUserNotificationCenter = .current()) {
        DoseNotification.registerCategories(on: center)
    }

    static func makeCategory() -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category,
            actions: [
                UNNotificationAction(identifier: add100, title: String(localized: "+100 ml", bundle: .module), options: []),
                UNNotificationAction(identifier: add250, title: String(localized: "+250 ml", bundle: .module), options: []),
                UNNotificationAction(identifier: add500, title: String(localized: "+500 ml", bundle: .module), options: []),
            ],
            intentIdentifiers: []
        )
    }

    public static func amountML(for action: String) -> Double? {
        switch action {
        case add100: 100
        case add250: 250
        case add500: 500
        default: nil
        }
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
        content.categoryIdentifier = reminder.category
        content.threadIdentifier = reminder.threadIdentifier
        if reminder.category == DoseNotification.category {
            content.userInfo = DoseNotification.userInfo(for: reminder)
        }
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
