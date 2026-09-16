import Foundation

// Wire formats. Every record carries a stable id and `updatedAt`; receivers apply
// last-writer-wins, so processing the same record twice (or out of date) is a no-op.
// Deletions are soft (`deletedAt`), which keeps the protocol upsert-only.

public struct FluidRecord: Codable, Hashable, Sendable {
    public var id: UUID
    public var amountML: Double
    public var beverage: BeverageType
    public var calories: Double
    public var timestamp: Date
    public var updatedAt: Date
    public var deletedAt: Date?
}

public struct FoodRecord: Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var calories: Double
    public var timestamp: Date
    public var updatedAt: Date
    public var deletedAt: Date?
}

/// Dose logs are matched by `doseKey`, not `id`: two devices logging the same dose
/// independently must converge on one log.
public struct DoseRecord: Codable, Hashable, Sendable {
    public var id: UUID
    public var medicationID: UUID
    public var doseKey: String
    public var scheduledTime: Date
    public var takenAt: Date?
    public var status: DoseLogStatus
    public var updatedAt: Date
    public var deletedAt: Date?
}

public struct MedicationRecord: Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var dosage: Double
    public var unit: String
    public var notes: String
    public var schedule: MedicationSchedule
    public var isActive: Bool
    public var updatedAt: Date
    public var deletedAt: Date?
}

public struct PresetRecord: Codable, Hashable, Sendable {
    public var id: UUID
    public var name: String
    public var calories: Double
    public var updatedAt: Date
    public var deletedAt: Date?
}

public enum SyncRecord: Codable, Hashable, Sendable {
    case fluid(FluidRecord)
    case food(FoodRecord)
    case dose(DoseRecord)

    public var id: UUID {
        switch self {
        case .fluid(let r): r.id
        case .food(let r): r.id
        case .dose(let r): r.id
        }
    }

    public var updatedAt: Date {
        switch self {
        case .fluid(let r): r.updatedAt
        case .food(let r): r.updatedAt
        case .dose(let r): r.updatedAt
        }
    }
}

/// Configuration owned by the iPhone and mirrored to the Watch as a whole
/// (latest state wins, delivered via application context).
public struct SettingsSnapshot: Codable, Hashable, Sendable {
    public var hydrationGoalML: Double
    public var calorieGoal: Double
    public var goalsUpdatedAt: Date
    public var medications: [MedicationRecord]
    public var presets: [PresetRecord]
}

public enum SyncMessage: Codable, Hashable, Sendable {
    case record(SyncRecord)
    case snapshot(SettingsSnapshot)
    /// Sent by a freshly installed counterpart that wants recent history.
    case backfillRequest
}

enum LastWriterWins {
    /// Strictly newer wins; equal timestamps keep what is stored (idempotent re-delivery).
    static func shouldApply(incoming: Date, existing: Date?) -> Bool {
        guard let existing else { return true }
        return incoming > existing
    }
}
