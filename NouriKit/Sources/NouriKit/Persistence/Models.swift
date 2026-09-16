import Foundation
import SwiftData

// SwiftData entities. No unique constraints and every attribute has a default,
// which keeps the schema compatible with a future CloudKit-backed container.
// Uniqueness by id is enforced by `NouriStore` upserts.

@Model
public final class FluidEntry {
    public var id: UUID = UUID()
    public var amountML: Double = 0
    public var beverageRaw: String = BeverageType.water.rawValue
    public var calories: Double = 0
    public var timestamp: Date = Date.distantPast
    public var updatedAt: Date = Date.distantPast
    public var deletedAt: Date?

    init(record: FluidRecord) {
        id = record.id
        apply(record)
    }

    func apply(_ r: FluidRecord) {
        amountML = r.amountML
        beverageRaw = r.beverage.rawValue
        calories = r.calories
        timestamp = r.timestamp
        updatedAt = r.updatedAt
        deletedAt = r.deletedAt
    }

    var record: FluidRecord {
        FluidRecord(id: id, amountML: amountML, beverage: BeverageType(rawValue: beverageRaw) ?? .other,
                    calories: calories, timestamp: timestamp, updatedAt: updatedAt, deletedAt: deletedAt)
    }

    var item: FluidItem {
        FluidItem(id: id, amountML: amountML, beverage: BeverageType(rawValue: beverageRaw) ?? .other,
                  calories: calories, timestamp: timestamp)
    }
}

@Model
public final class FoodEntry {
    public var id: UUID = UUID()
    public var name: String = ""
    public var calories: Double = 0
    public var timestamp: Date = Date.distantPast
    public var updatedAt: Date = Date.distantPast
    public var deletedAt: Date?

    init(record: FoodRecord) {
        id = record.id
        apply(record)
    }

    func apply(_ r: FoodRecord) {
        name = r.name
        calories = r.calories
        timestamp = r.timestamp
        updatedAt = r.updatedAt
        deletedAt = r.deletedAt
    }

    var record: FoodRecord {
        FoodRecord(id: id, name: name, calories: calories, timestamp: timestamp, updatedAt: updatedAt, deletedAt: deletedAt)
    }

    var item: FoodItem { FoodItem(id: id, name: name, calories: calories, timestamp: timestamp) }
}

@Model
public final class Medication {
    public var id: UUID = UUID()
    public var name: String = ""
    public var dosage: Double = 1
    public var unit: String = ""
    public var notes: String = ""
    /// JSON-encoded `MedicationSchedule`; lets the schedule evolve without schema migrations.
    public var scheduleData: Data = Data()
    public var isActive: Bool = true
    public var updatedAt: Date = Date.distantPast
    public var deletedAt: Date?

    init(record: MedicationRecord) {
        id = record.id
        apply(record)
    }

    func apply(_ r: MedicationRecord) {
        name = r.name
        dosage = r.dosage
        unit = r.unit
        notes = r.notes
        scheduleData = (try? JSONEncoder().encode(r.schedule)) ?? Data()
        isActive = r.isActive
        updatedAt = r.updatedAt
        deletedAt = r.deletedAt
    }

    var schedule: MedicationSchedule {
        (try? JSONDecoder().decode(MedicationSchedule.self, from: scheduleData)) ?? MedicationSchedule(times: [])
    }

    var record: MedicationRecord {
        MedicationRecord(id: id, name: name, dosage: dosage, unit: unit, notes: notes, schedule: schedule,
                         isActive: isActive, updatedAt: updatedAt, deletedAt: deletedAt)
    }

    var info: MedicationInfo {
        MedicationInfo(id: id, name: name, dosage: dosage, unit: unit, notes: notes, schedule: schedule, isActive: isActive)
    }
}

/// A medication definition says what *should* happen; a log records what *did* happen.
@Model
public final class MedicationLog {
    public var id: UUID = UUID()
    public var medicationID: UUID = UUID()
    public var doseKey: String = ""
    public var scheduledTime: Date = Date.distantPast
    public var takenAt: Date?
    public var statusRaw: String = DoseLogStatus.taken.rawValue
    public var updatedAt: Date = Date.distantPast
    public var deletedAt: Date?

    init(record: DoseRecord) {
        id = record.id
        apply(record)
    }

    func apply(_ r: DoseRecord) {
        medicationID = r.medicationID
        doseKey = r.doseKey
        scheduledTime = r.scheduledTime
        takenAt = r.takenAt
        statusRaw = r.status.rawValue
        updatedAt = r.updatedAt
        deletedAt = r.deletedAt
    }

    var status: DoseLogStatus { DoseLogStatus(rawValue: statusRaw) ?? .taken }

    var record: DoseRecord {
        DoseRecord(id: id, medicationID: medicationID, doseKey: doseKey, scheduledTime: scheduledTime,
                   takenAt: takenAt, status: status, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

@Model
public final class CaloriePreset {
    public var id: UUID = UUID()
    public var name: String = ""
    public var calories: Double = 0
    public var updatedAt: Date = Date.distantPast
    public var deletedAt: Date?

    init(record: PresetRecord) {
        id = record.id
        apply(record)
    }

    func apply(_ r: PresetRecord) {
        name = r.name
        calories = r.calories
        updatedAt = r.updatedAt
        deletedAt = r.deletedAt
    }

    var record: PresetRecord {
        PresetRecord(id: id, name: name, calories: calories, updatedAt: updatedAt, deletedAt: deletedAt)
    }
}

@Model
public final class UserPreferences {
    public var hydrationGoalML: Double = 2500
    public var calorieGoal: Double = 2000
    public var updatedAt: Date = Date.distantPast

    init() {}
}

public struct PresetInfo: Hashable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var calories: Double
}
