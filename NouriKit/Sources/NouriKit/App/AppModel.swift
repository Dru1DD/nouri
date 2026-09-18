import Foundation
import Observation
#if canImport(WidgetKit)
import WidgetKit
#endif

/// Shared iPhone/Watch façade. Owns the orchestration of every user action:
/// write to the store, publish to the paired device, mirror to Health, reschedule
/// reminders, refresh widgets. Optional services are simply absent where they don't apply.
@MainActor
@Observable
public final class AppModel {
    public private(set) var today: DaySummary
    public private(set) var medications: [MedicationInfo] = []
    public private(set) var presets: [PresetInfo] = []
    public private(set) var imported: ImportedTotals?
    public private(set) var hydrationGoal: Double = 2500
    public private(set) var calorieGoal: Double = 2000
    public private(set) var scheduledReminderCount = 0
    public private(set) var healthConnected = false
    /// `nil` until asked. Asked lazily, when the user first creates a medication.
    public private(set) var notificationsAllowed: Bool?

    @ObservationIgnored public let store: NouriStore
    @ObservationIgnored private let sync: SyncEngine?
    @ObservationIgnored private let health: HealthService?
    @ObservationIgnored private let reminders: ReminderScheduler?
    @ObservationIgnored private let plansReminders: Bool
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: () -> Calendar

    public init(
        store: NouriStore,
        transport: SyncTransport? = nil,
        health: HealthService? = nil,
        reminders: ReminderScheduler? = nil,
        plansReminders: Bool = true,
        now: @escaping () -> Date = Date.init,
        calendar: @escaping () -> Calendar = { Calendar.autoupdatingCurrent }
    ) {
        self.store = store
        self.health = health
        self.reminders = reminders
        self.plansReminders = plansReminders
        self.now = now
        self.calendar = calendar
        self.sync = transport.map { SyncEngine(store: store, transport: $0, now: now) }
        today = store.summary(for: now(), now: now(), calendar: calendar())
        sync?.onRemoteChange = { [weak self] records in self?.handleRemote(records) }
        transport?.onFirstActivation = { [weak self] in
            guard let self else { return }
            #if os(watchOS)
            sync?.requestBackfill()
            #else
            sync?.publishSettings()
            #endif
        }
        refresh()
    }

    // MARK: - Lifecycle

    /// Call on launch, on foreground, and on time-zone / significant-time changes.
    public func refresh() {
        let date = now()
        today = store.summary(for: date, now: date, calendar: calendar())
        medications = store.medications()
        presets = store.presets()
        let prefs = store.preferences()
        hydrationGoal = prefs.hydrationGoalML
        calorieGoal = prefs.calorieGoal
    }

    public func refreshExternal() async {
        guard let health, let interval = calendar().dateInterval(of: .day, for: now()) else { return }
        healthConnected = health.isConnected
        imported = await health.importedTotals(in: interval)
    }

    public var isHealthAvailable: Bool { health != nil }

    public func requestNotificationPermission() async {
        guard let reminders else { return }
        notificationsAllowed = await reminders.client.requestAuthorization()
    }

    public func connectHealth() async {
        await health?.requestAuthorization()
        await refreshExternal()
    }

    /// On the Watch `plansReminders` is false: the iPhone owns dose reminders (mirrored by the
    /// system), the Watch only schedules snoozes it was asked for.
    public func rescheduleReminders() async {
        guard let reminders, plansReminders else { return }
        let date = now(), cal = calendar()
        let horizon = DateInterval(start: cal.startOfDay(for: date), duration: Double(ReminderPlanner.horizonDays + 1) * 86_400)
        let resolved = Set(store.doseLogs(around: horizon).filter { $0.value.status != .missed }.keys)
        let plan = ReminderPlanner.plan(medications: store.medications(), resolvedKeys: resolved, now: date, calendar: cal)
        await reminders.apply(plan)
        scheduledReminderCount = plan.count
        refresh()
    }

    public func history(days: Int) -> [DaySummary] {
        let cal = calendar(), date = now()
        return (0..<days).compactMap { offset in
            cal.date(byAdding: .day, value: -offset, to: date).map { store.summary(for: $0, now: date, calendar: cal) }
        }
    }

    // MARK: - Entries

    /// Adds a drink. `timestamp` defaults to now; past times are allowed, future ones are clamped.
    public func addFluid(_ amountML: Double, beverage: BeverageType = .water, calories: Double? = nil, timestamp: Date? = nil) {
        guard amountML > 0 else { return }
        let date = now()
        let kcal = max(calories ?? beverage.defaultCalories(amountML: amountML), 0)
        let record = store.addFluid(amountML: amountML, beverage: beverage, calories: kcal,
                                    timestamp: min(timestamp ?? date, date), at: date)
        lastAdded = LastAdded(id: record.id, kind: .fluid(amountML: amountML, beverage: beverage))
        localChange(record)
    }

    /// Adds food. An empty name is stored as empty; views show a localized "Quick add" instead.
    public func addCalories(_ kcal: Double, name: String = "", timestamp: Date? = nil) {
        guard kcal > 0 else { return }
        let date = now()
        let record = store.addFood(name: name.trimmingCharacters(in: .whitespacesAndNewlines), calories: kcal,
                                   timestamp: min(timestamp ?? date, date), at: date)
        lastAdded = LastAdded(id: record.id, kind: .food(kcal: kcal))
        localChange(record)
    }

    public func updateFluid(_ item: FluidItem) {
        guard item.amountML > 0 else { return }
        var item = item
        item.calories = max(item.calories, 0)
        item.timestamp = min(item.timestamp, now())
        store.updateFluid(item, at: now()).map(localChange)
    }

    public func updateFood(_ item: FoodItem) {
        guard item.calories > 0 else { return }
        var item = item
        item.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.timestamp = min(item.timestamp, now())
        store.updateFood(item, at: now()).map(localChange)
    }

    public func deleteEntry(id: UUID) {
        if lastAdded?.id == id { lastAdded = nil }
        store.deleteEntry(id: id, at: now()).map(localChange)
    }

    // MARK: - Undo

    public struct LastAdded: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            case fluid(amountML: Double, beverage: BeverageType)
            case food(kcal: Double)
        }
        public let id: UUID
        public let kind: Kind
    }

    /// The most recent quick add, offered for undo for a few seconds by the UI.
    public private(set) var lastAdded: LastAdded?

    public func undoLastAdd() {
        guard let lastAdded else { return }
        deleteEntry(id: lastAdded.id)
    }

    /// Hides the undo offer, unless a newer entry replaced it meanwhile.
    public func dismissUndo(id: UUID) {
        if lastAdded?.id == id { lastAdded = nil }
    }

    // MARK: - Medications

    public func setDose(_ dose: DoseOccurrence, status: DoseLogStatus?) async {
        await setDose(key: dose.key, medicationID: dose.medicationID, scheduledAt: dose.scheduledAt, status: status)
    }

    public func setDose(key: String, medicationID: UUID, scheduledAt: Date, status: DoseLogStatus?) async {
        localChange(store.logDose(key: key, medicationID: medicationID, scheduledAt: scheduledAt, status: status, at: now()))
        if status != nil { await reminders?.clear(doseKey: key) }
        await rescheduleReminders()
    }

    public func snooze(_ dose: DoseOccurrence, minutes: Int = 10) async {
        await reminders?.snooze(dose, now: now(), minutes: minutes)
    }

    /// Handles a tap on a notification action (Taken / Skip / Snooze).
    public func handleNotificationAction(_ action: String, payload: DoseNotification.Payload) async {
        switch action {
        case DoseNotification.takenAction:
            await setDose(key: payload.doseKey, medicationID: payload.medicationID, scheduledAt: payload.scheduledAt, status: .taken)
        case DoseNotification.skipAction:
            await setDose(key: payload.doseKey, medicationID: payload.medicationID, scheduledAt: payload.scheduledAt, status: .skipped)
        case DoseNotification.snoozeAction:
            let med = store.medications().first { $0.id == payload.medicationID }
            let dose = DoseOccurrence(medicationID: payload.medicationID, medicationName: med?.name ?? String(localized: "medication", bundle: .module),
                                      dosageText: med?.dosageText ?? "", time: TimeOfDay(hour: 0, minute: 0),
                                      scheduledAt: payload.scheduledAt, key: payload.doseKey)
            await snooze(dose)
        default:
            break
        }
    }

    public func saveMedication(_ info: MedicationInfo) async {
        store.saveMedication(info, at: now())
        if notificationsAllowed == nil { await requestNotificationPermission() }
        settingsChanged()
        await rescheduleReminders()
    }

    public func deleteMedication(id: UUID) async {
        store.deleteMedication(id: id, at: now())
        settingsChanged()
        await rescheduleReminders()
    }

    // MARK: - Settings

    public func setGoals(hydrationML: Double, calories: Double) {
        store.setGoals(hydrationML: max(hydrationML, 1), calories: max(calories, 1), at: now())
        settingsChanged()
    }

    public func addPreset(name: String, calories: Double) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, calories > 0 else { return }
        store.addPreset(name: trimmed, calories: calories, at: now())
        settingsChanged()
    }

    public func deletePreset(id: UUID) {
        store.deletePreset(id: id, at: now())
        settingsChanged()
    }

    // MARK: - Private

    private func localChange(_ record: SyncRecord) {
        sync?.publish(record)
        exportToHealth([record])
        didChange()
    }

    private func settingsChanged() {
        sync?.publishSettings()
        didChange()
    }

    private func handleRemote(_ records: [SyncRecord]) {
        exportToHealth(records)
        didChange()
        // A dose resolved on the other device: drop its pending/delivered notifications here too.
        let resolvedKeys = records.compactMap { record -> String? in
            guard case .dose(let d) = record, d.deletedAt == nil else { return nil }
            return d.doseKey
        }
        Task {
            for key in resolvedKeys { await reminders?.clear(doseKey: key) }
            await rescheduleReminders()
        }
    }

    private func exportToHealth(_ records: [SyncRecord]) {
        guard let health else { return }
        Task {
            for record in records { await health.export(record) }
        }
    }

    private func didChange() {
        refresh()
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
