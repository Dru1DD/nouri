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

/// Interval + quiet-hours hydration reminders for the remainder of today and tomorrow.
/// Today is skipped once the goal is met; tomorrow is still planned.
public enum HydrationReminderPlanner {
    public static let prefix = "hydrate."

    /// - `quietStart/EndMinutes`: night quiet, may wrap past midnight (22:00–08:00).
    /// - `daytimeQuiet`: optional same-day break in minutes from midnight (e.g. 12:00..<14:00).
    /// - The grid runs from the first awake minute of the day, or from `lastDrinkAt + interval`
    ///   when there was a drink today. It never depends on `now`, so rescheduling is idempotent.
    public static func plan(
        enabled: Bool,
        intervalMinutes: Int,
        quietStartMinutes: Int,
        quietEndMinutes: Int,
        daytimeQuiet: Range<Int>? = nil,
        todayHydrationML: Double,
        goalML: Double,
        now: Date,
        calendar: Calendar,
        maxCount: Int,
        horizonDays: Int = 2,
        lastDrinkAt: Date? = nil
    ) -> [PlannedReminder] {
        guard enabled, maxCount > 0, intervalMinutes > 0 else { return [] }

        var quiet = [(quietStartMinutes, quietEndMinutes)]
        if let daytimeQuiet { quiet.append((daytimeQuiet.lowerBound, daytimeQuiet.upperBound)) }
        let dayStart = calendar.startOfDay(for: now)
        let step = TimeInterval(intervalMinutes * 60)
        var result: [PlannedReminder] = []
        for offset in 0..<horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: dayStart) else { continue }
            let isToday = offset == 0
            if isToday, todayHydrationML >= goalML { continue }

            let windows = awakeWindows(on: day, quiet: quiet, calendar: calendar)
            guard var cursor = windows.first?.start else { continue }
            if isToday, let last = lastDrinkAt, calendar.isDate(last, inSameDayAs: now) {
                cursor = max(last.addingTimeInterval(step), cursor)
            }
            // A slot that lands in quiet time moves to the end of it, and the grid continues from there.
            while let window = windows.first(where: { cursor < $0.end }) {
                cursor = max(cursor, window.start)
                if cursor > now {
                    guard result.count < maxCount else { return result }
                    result.append(reminder(at: cursor, calendar: calendar))
                }
                cursor = cursor.addingTimeInterval(step)
            }
        }
        return result
    }

    /// The parts of `day` outside every quiet range. Ranges are minutes from midnight; one whose
    /// start is after its end wraps past midnight; equal start and end means no quiet time.
    public static func awakeWindows(on day: Date, quiet: [(start: Int, end: Int)], calendar: Calendar) -> [DateInterval] {
        let dayMinutes = 24 * 60
        var blocked: [(Int, Int)] = []
        for (start, end) in quiet where start != end {
            if start < end {
                blocked.append((start, end))
            } else {
                blocked.append((start, dayMinutes))
                blocked.append((0, end))
            }
        }
        var awake: [(Int, Int)] = []
        var free = 0
        for (start, end) in blocked.sorted(by: { $0.0 < $1.0 }) {
            if start > free { awake.append((free, start)) }
            free = max(free, end)
        }
        if free < dayMinutes { awake.append((free, dayMinutes)) }

        let startOfDay = calendar.startOfDay(for: day)
        return awake.compactMap { start, end in
            guard let from = calendar.date(byAdding: .minute, value: start, to: startOfDay),
                  let to = calendar.date(byAdding: .minute, value: end, to: startOfDay) else { return nil }
            return DateInterval(start: from, end: to)
        }
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
