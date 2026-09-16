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
    /// `nil` until asked. Asked lazily, when the user first creates a medication.
    public private(set) var notificationsAllowed: Bool?

    @ObservationIgnored public let store: NouriStore
    @ObservationIgnored private let sync: SyncEngine?
    @ObservationIgnored private let health: HealthService?
    @ObservationIgnored private let reminders: ReminderScheduler?
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: () -> Calendar

    public init(
        store: NouriStore,
        transport: SyncTransport? = nil,
        health: HealthService? = nil,
        reminders: ReminderScheduler? = nil,
        now: @escaping () -> Date = Date.init,
        calendar: @escaping () -> Calendar = { Calendar.autoupdatingCurrent }
    ) {
        self.store = store
        self.health = health
        self.reminders = reminders
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

    public func rescheduleReminders() async {
        guard let reminders else { return }
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

    public func addFluid(_ amountML: Double, beverage: BeverageType = .water, calories: Double? = nil) {
        guard amountML > 0 else { return }
        let kcal = max(calories ?? beverage.defaultCalories(amountML: amountML), 0)
        localChange(store.addFluid(amountML: amountML, beverage: beverage, calories: kcal, at: now()))
    }

    public func addCalories(_ kcal: Double, name: String = "Quick add") {
        guard kcal > 0 else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        localChange(store.addFood(name: trimmed.isEmpty ? "Quick add" : trimmed, calories: kcal, at: now()))
    }

    public func deleteEntry(id: UUID) {
        store.deleteEntry(id: id, at: now()).map(localChange)
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
            let dose = DoseOccurrence(medicationID: payload.medicationID, medicationName: med?.name ?? "medication",
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
        Task { await rescheduleReminders() }
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
