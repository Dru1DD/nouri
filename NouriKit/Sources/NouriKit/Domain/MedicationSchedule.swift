import Foundation

/// A wall-clock time. Schedules are expressed in local time: "08:00" means 08:00
/// in whatever time zone the device is currently in.
public struct TimeOfDay: Codable, Hashable, Comparable, Sendable {
    public var hour: Int
    public var minute: Int

    public init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    public static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
        (lhs.hour, lhs.minute) < (rhs.hour, rhs.minute)
    }

    public var dateComponents: DateComponents { DateComponents(hour: hour, minute: minute) }
}

public struct MedicationSchedule: Codable, Hashable, Sendable {
    public var times: [TimeOfDay]
    /// `Calendar` weekday numbers (1 = Sunday … 7 = Saturday). Empty means every day.
    public var weekdays: Set<Int>
    public var startDate: Date?
    public var endDate: Date?

    public init(times: [TimeOfDay], weekdays: Set<Int> = [], startDate: Date? = nil, endDate: Date? = nil) {
        self.times = times
        self.weekdays = weekdays
        self.startDate = startDate
        self.endDate = endDate
    }

    /// Absolute fire dates for every dose on the calendar day containing `day`.
    /// Non-existent local times (DST spring-forward gap) move to the next valid instant;
    /// repeated local times (DST fall-back) resolve to the first occurrence.
    public func doseDates(on day: Date, calendar: Calendar) -> [(TimeOfDay, Date)] {
        let dayStart = calendar.startOfDay(for: day)
        if !weekdays.isEmpty, !weekdays.contains(calendar.component(.weekday, from: dayStart)) { return [] }
        if let startDate, dayStart < calendar.startOfDay(for: startDate) { return [] }
        if let endDate, dayStart > calendar.startOfDay(for: endDate) { return [] }

        return Set(times).sorted().compactMap { time in
            guard let date = calendar.nextDate(
                after: dayStart.addingTimeInterval(-1),
                matching: time.dateComponents,
                matchingPolicy: .nextTime,
                repeatedTimePolicy: .first,
                direction: .forward
            ), calendar.isDate(date, inSameDayAs: dayStart) else { return nil }
            return (time, date)
        }
    }
}

/// One scheduled dose of one medication.
public struct DoseOccurrence: Hashable, Identifiable, Sendable {
    public let medicationID: UUID
    public let medicationName: String
    public let dosageText: String
    public let time: TimeOfDay
    public let scheduledAt: Date
    /// Stable identity of the dose: medication + local calendar day + wall-clock time.
    /// Independent of time zone, so a dose logged before travelling stays logged after.
    public let key: String

    public var id: String { key }

    public static func key(medicationID: UUID, day: Date, time: TimeOfDay, calendar: Calendar) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: day)
        return String(format: "%@|%04d-%02d-%02d|%02d:%02d",
                      medicationID.uuidString, c.year ?? 0, c.month ?? 0, c.day ?? 0, time.hour, time.minute)
    }
}

/// Plain value snapshot of a medication, so domain logic never touches SwiftData.
public struct MedicationInfo: Hashable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var dosage: Double
    public var unit: String
    public var notes: String
    public var schedule: MedicationSchedule
    public var isActive: Bool

    public init(id: UUID = UUID(), name: String, dosage: Double, unit: String, notes: String = "",
                schedule: MedicationSchedule, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.dosage = dosage
        self.unit = unit
        self.notes = notes
        self.schedule = schedule
        self.isActive = isActive
    }

    public var dosageText: String {
        "\(dosage.formatted(.number.precision(.fractionLength(0...2)))) \(unit)"
    }

    public func occurrences(on day: Date, calendar: Calendar) -> [DoseOccurrence] {
        guard isActive else { return [] }
        return schedule.doseDates(on: day, calendar: calendar).map { time, date in
            DoseOccurrence(medicationID: id, medicationName: name, dosageText: dosageText, time: time,
                           scheduledAt: date, key: DoseOccurrence.key(medicationID: id, day: day, time: time, calendar: calendar))
        }
    }
}

public enum DoseLogStatus: String, Codable, CaseIterable, Sendable {
    case taken, skipped, missed
}

public enum DoseStatus: String, Sendable {
    case upcoming, due, taken, skipped, missed

    /// How long after the scheduled time a dose without a log is still "due" rather than "missed".
    public static let gracePeriod: TimeInterval = 60 * 60

    public static func resolve(scheduledAt: Date, log: DoseLogStatus?, now: Date) -> DoseStatus {
        switch log {
        case .taken: return .taken
        case .skipped: return .skipped
        case .missed: return .missed
        case nil:
            if now < scheduledAt { return .upcoming }
            return now < scheduledAt.addingTimeInterval(gracePeriod) ? .due : .missed
        }
    }

    /// Text + symbol so status never relies on color alone.
    public var label: String {
        switch self {
        case .upcoming: "Upcoming"
        case .due: "Due now"
        case .taken: "Taken"
        case .skipped: "Skipped"
        case .missed: "Missed"
        }
    }

    public var symbol: String {
        switch self {
        case .upcoming: "clock"
        case .due: "bell.badge"
        case .taken: "checkmark.circle.fill"
        case .skipped: "arrow.uturn.right.circle"
        case .missed: "exclamationmark.triangle.fill"
        }
    }

    public var isResolved: Bool { self == .taken || self == .skipped }
}
