import Foundation
import SwiftData

/// The only type that talks to SwiftData. Views and features go through `AppModel`,
/// which goes through here. Every local write returns the `SyncRecord` to publish.
/// Not `Sendable`: each owner (the app's `AppModel`, a widget timeline call) uses its own instance.
public final class NouriStore {
    public static let appGroup = "group.com.dru1dd.nouri"

    public let context: ModelContext

    public init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([FluidEntry.self, FoodEntry.self, Medication.self, MedicationLog.self,
                             CaloriePreset.self, UserPreferences.self])
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else if let group = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            // Shared with the widget extension on the same device. SwiftData doesn't create the
            // directory up front on first launch (noisy CoreData recovery), so make sure it exists.
            let dir = group.appending(path: "Library/Application Support", directoryHint: .isDirectory)
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            config = ModelConfiguration(schema: schema, url: dir.appending(path: "default.store"))
        } else {
            config = ModelConfiguration(schema: schema)
        }
        return try ModelContainer(for: schema, configurations: config)
    }

    // MARK: - Reads

    public func fluids(in interval: DateInterval) -> [FluidItem] {
        let start = interval.start, end = interval.end
        return fetch(FetchDescriptor<FluidEntry>(
            predicate: #Predicate { $0.deletedAt == nil && $0.timestamp >= start && $0.timestamp < end },
            sortBy: [SortDescriptor(\.timestamp)]
        )).map(\.item)
    }

    public func foods(in interval: DateInterval) -> [FoodItem] {
        let start = interval.start, end = interval.end
        return fetch(FetchDescriptor<FoodEntry>(
            predicate: #Predicate { $0.deletedAt == nil && $0.timestamp >= start && $0.timestamp < end },
            sortBy: [SortDescriptor(\.timestamp)]
        )).map(\.item)
    }

    public func medications() -> [MedicationInfo] {
        fetch(FetchDescriptor<Medication>(predicate: #Predicate { $0.deletedAt == nil }, sortBy: [SortDescriptor(\.name)]))
            .map(\.info)
    }

    public func presets() -> [PresetInfo] {
        fetch(FetchDescriptor<CaloriePreset>(predicate: #Predicate { $0.deletedAt == nil }, sortBy: [SortDescriptor(\.name)]))
            .map { PresetInfo(id: $0.id, name: $0.name, calories: $0.calories) }
    }

    /// Logs keyed by dose key, covering doses scheduled in `interval` (padded a day either
    /// side so doses whose local day differs from the UTC instant are still found).
    public func doseLogs(around interval: DateInterval) -> [String: (status: DoseLogStatus, at: Date?)] {
        let start = interval.start.addingTimeInterval(-86_400), end = interval.end.addingTimeInterval(86_400)
        let logs = fetch(FetchDescriptor<MedicationLog>(
            predicate: #Predicate { $0.deletedAt == nil && $0.scheduledTime >= start && $0.scheduledTime < end }
        ))
        return Dictionary(logs.map { ($0.doseKey, (status: $0.status, at: $0.takenAt)) }, uniquingKeysWith: { a, _ in a })
    }

    public func preferences() -> UserPreferences {
        if let existing = fetch(FetchDescriptor<UserPreferences>()).first { return existing }
        let prefs = UserPreferences()
        context.insert(prefs)
        save()
        return prefs
    }

    public func summary(for day: Date, now: Date, calendar: Calendar) -> DaySummary {
        let interval = calendar.dateInterval(of: .day, for: day) ?? DateInterval(start: day, duration: 86_400)
        let prefs = preferences()
        return DaySummary.build(
            day: day,
            fluids: fluids(in: interval),
            foods: foods(in: interval),
            medications: medications(),
            logs: doseLogs(around: interval),
            hydrationGoalML: prefs.hydrationGoalML,
            calorieGoal: prefs.calorieGoal,
            now: now,
            calendar: calendar
        )
    }

    // MARK: - Local writes

    /// `timestamp` is when it was consumed (may be in the past); `date` is when the write happens.
    public func addFluid(amountML: Double, beverage: BeverageType, calories: Double, timestamp: Date? = nil,
                         at date: Date) -> SyncRecord {
        upsert(.fluid(FluidRecord(id: UUID(), amountML: amountML, beverage: beverage, calories: calories,
                                  timestamp: timestamp ?? date, updatedAt: date, deletedAt: nil)))
    }

    public func addFood(name: String, calories: Double, timestamp: Date? = nil, at date: Date) -> SyncRecord {
        upsert(.food(FoodRecord(id: UUID(), name: name, calories: calories, timestamp: timestamp ?? date,
                                updatedAt: date, deletedAt: nil)))
    }

    public func updateFluid(_ item: FluidItem, at date: Date) -> SyncRecord? {
        guard var r = fetchFluid(item.id)?.record else { return nil }
        r.amountML = item.amountML
        r.beverage = item.beverage
        r.calories = item.calories
        r.timestamp = item.timestamp
        r.updatedAt = Self.stamp(date, after: r.updatedAt)
        return upsert(.fluid(r))
    }

    public func updateFood(_ item: FoodItem, at date: Date) -> SyncRecord? {
        guard var r = fetchFood(item.id)?.record else { return nil }
        r.name = item.name
        r.calories = item.calories
        r.timestamp = item.timestamp
        r.updatedAt = Self.stamp(date, after: r.updatedAt)
        return upsert(.food(r))
    }

    public func deleteEntry(id: UUID, at date: Date) -> SyncRecord? {
        if var r = fetchFluid(id)?.record {
            r.updatedAt = Self.stamp(date, after: r.updatedAt)
            r.deletedAt = r.updatedAt
            return upsert(.fluid(r))
        }
        if var r = fetchFood(id)?.record {
            r.updatedAt = Self.stamp(date, after: r.updatedAt)
            r.deletedAt = r.updatedAt
            return upsert(.food(r))
        }
        return nil
    }

    /// `status == nil` clears the log (undo).
    public func logDose(key: String, medicationID: UUID, scheduledAt: Date, status: DoseLogStatus?, at date: Date) -> SyncRecord {
        let existing = fetchLog(key)
        let record = DoseRecord(
            id: existing?.id ?? UUID(),
            medicationID: medicationID,
            doseKey: key,
            scheduledTime: scheduledAt,
            takenAt: status == nil ? nil : date,
            status: status ?? .taken,
            updatedAt: Self.stamp(date, after: existing?.updatedAt),
            deletedAt: status == nil ? date : nil
        )
        return upsert(.dose(record))
    }

    public func saveMedication(_ info: MedicationInfo, at date: Date) {
        applyMedication(MedicationRecord(id: info.id, name: info.name, dosage: info.dosage, unit: info.unit,
                                         notes: info.notes, schedule: info.schedule, isActive: info.isActive,
                                         updatedAt: Self.stamp(date, after: fetchMedication(info.id)?.updatedAt),
                                         deletedAt: nil))
        save()
    }

    public func deleteMedication(id: UUID, at date: Date) {
        guard var r = fetchMedication(id)?.record else { return }
        r.updatedAt = Self.stamp(date, after: r.updatedAt)
        r.deletedAt = r.updatedAt
        applyMedication(r)
        save()
    }

    public func addPreset(name: String, calories: Double, at date: Date) {
        context.insert(CaloriePreset(record: PresetRecord(id: UUID(), name: name, calories: calories, updatedAt: date)))
        save()
    }

    public func deletePreset(id: UUID, at date: Date) {
        let target = fetch(FetchDescriptor<CaloriePreset>(predicate: #Predicate { $0.id == id })).first
        guard let target else { return }
        target.updatedAt = Self.stamp(date, after: target.updatedAt)
        target.deletedAt = target.updatedAt
        save()
    }

    public func setGoals(hydrationML: Double, calories: Double, at date: Date) {
        let prefs = preferences()
        prefs.hydrationGoalML = hydrationML
        prefs.calorieGoal = calories
        prefs.updatedAt = Self.stamp(date, after: prefs.updatedAt)
        save()
    }

    // MARK: - Sync

    /// Idempotent last-writer-wins upsert. Returns whether anything changed.
    @discardableResult
    public func apply(_ record: SyncRecord) -> Bool {
        let changed: Bool
        switch record {
        case .fluid(let r):
            let existing = fetchFluid(r.id)
            changed = LastWriterWins.shouldApply(incoming: r.updatedAt, existing: existing?.updatedAt)
            if changed { existing.map { $0.apply(r) } ?? context.insert(FluidEntry(record: r)) }
        case .food(let r):
            let existing = fetchFood(r.id)
            changed = LastWriterWins.shouldApply(incoming: r.updatedAt, existing: existing?.updatedAt)
            if changed { existing.map { $0.apply(r) } ?? context.insert(FoodEntry(record: r)) }
        case .dose(let r):
            let existing = fetchLog(r.doseKey)
            changed = LastWriterWins.shouldApply(incoming: r.updatedAt, existing: existing?.updatedAt)
            if changed {
                var r = r
                r.id = existing?.id ?? r.id  // one log per dose, whichever device created it first
                existing.map { $0.apply(r) } ?? context.insert(MedicationLog(record: r))
            }
        }
        if changed { save() }
        return changed
    }

    @discardableResult
    public func apply(_ snapshot: SettingsSnapshot) -> Bool {
        var changed = false
        let prefs = preferences()
        if LastWriterWins.shouldApply(incoming: snapshot.goalsUpdatedAt, existing: prefs.updatedAt) {
            prefs.hydrationGoalML = snapshot.hydrationGoalML
            prefs.calorieGoal = snapshot.calorieGoal
            prefs.updatedAt = snapshot.goalsUpdatedAt
            changed = true
        }
        for med in snapshot.medications { changed = applyMedication(med) || changed }
        for preset in snapshot.presets {
            let id = preset.id
            let existing = fetch(FetchDescriptor<CaloriePreset>(predicate: #Predicate { $0.id == id })).first
            if LastWriterWins.shouldApply(incoming: preset.updatedAt, existing: existing?.updatedAt) {
                existing.map { $0.apply(preset) } ?? context.insert(CaloriePreset(record: preset))
                changed = true
            }
        }
        if changed { save() }
        return changed
    }

    /// Includes soft-deleted rows so the receiver learns about deletions too.
    public func snapshot() -> SettingsSnapshot {
        let prefs = preferences()
        return SettingsSnapshot(
            hydrationGoalML: prefs.hydrationGoalML,
            calorieGoal: prefs.calorieGoal,
            goalsUpdatedAt: prefs.updatedAt,
            medications: fetch(FetchDescriptor<Medication>()).map(\.record),
            presets: fetch(FetchDescriptor<CaloriePreset>()).map(\.record)
        )
    }

    public func records(updatedSince date: Date) -> [SyncRecord] {
        fetch(FetchDescriptor<FluidEntry>(predicate: #Predicate { $0.updatedAt >= date })).map { .fluid($0.record) }
            + fetch(FetchDescriptor<FoodEntry>(predicate: #Predicate { $0.updatedAt >= date })).map { .food($0.record) }
            + fetch(FetchDescriptor<MedicationLog>(predicate: #Predicate { $0.updatedAt >= date })).map { .dose($0.record) }
    }

    // MARK: - Private

    /// A local write must always supersede what is stored, even with a coarse or skewed clock.
    static func stamp(_ date: Date, after existing: Date?) -> Date {
        guard let existing, existing >= date else { return date }
        return existing.addingTimeInterval(0.001)
    }

    private func upsert(_ record: SyncRecord) -> SyncRecord {
        apply(record)
        return record
    }

    @discardableResult
    private func applyMedication(_ r: MedicationRecord) -> Bool {
        let existing = fetchMedication(r.id)
        guard LastWriterWins.shouldApply(incoming: r.updatedAt, existing: existing?.updatedAt) else { return false }
        existing.map { $0.apply(r) } ?? context.insert(Medication(record: r))
        return true
    }

    private func fetchFluid(_ id: UUID) -> FluidEntry? {
        fetch(FetchDescriptor<FluidEntry>(predicate: #Predicate { $0.id == id })).first
    }

    private func fetchFood(_ id: UUID) -> FoodEntry? {
        fetch(FetchDescriptor<FoodEntry>(predicate: #Predicate { $0.id == id })).first
    }

    private func fetchMedication(_ id: UUID) -> Medication? {
        fetch(FetchDescriptor<Medication>(predicate: #Predicate { $0.id == id })).first
    }

    private func fetchLog(_ key: String) -> MedicationLog? {
        fetch(FetchDescriptor<MedicationLog>(predicate: #Predicate { $0.doseKey == key })).first
    }

    private func fetch<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> [T] {
        do { return try context.fetch(descriptor) } catch {
            assertionFailure("SwiftData fetch failed: \(error)")
            return []
        }
    }

    private func save() {
        do { try context.save() } catch {
            assertionFailure("SwiftData save failed: \(error)")
        }
    }
}
