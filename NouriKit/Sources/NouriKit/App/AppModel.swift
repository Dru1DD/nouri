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
    /// Recently logged drinks other than water, for one-tap repeats.
    public private(set) var recentDrinks: [FluidItem] = []
    public private(set) var imported: ImportedTotals?
    public private(set) var hydrationGoal: Double = 2500
    public private(set) var calorieGoal: Double = 2000
    public private(set) var hydrationRemindersEnabled = false
    public private(set) var hydrationReminderIntervalMinutes = 120
    public private(set) var quietHoursStartMinutes = 22 * 60
    public private(set) var quietHoursEndMinutes = 8 * 60
    public private(set) var daytimeQuietEnabled = false
    public private(set) var daytimeQuietStartMinutes = 13 * 60
    public private(set) var daytimeQuietEndMinutes = 14 * 60
    public private(set) var hasCompletedOnboarding = false
    public private(set) var caloriesEnabled = false
    public private(set) var appearancePreset: AppearancePreset = .default
    public private(set) var scheduledReminderCount = 0
    public private(set) var healthConnected = false
    /// Last persistence error suitable for a user-facing alert, if any.
    public private(set) var lastErrorMessage: String?
    /// `nil` until asked. Asked lazily, when the user first creates a medication or enables reminders.
    public private(set) var notificationsAllowed: Bool?

    @ObservationIgnored public let store: NouriStore
    @ObservationIgnored private let sync: SyncEngine?
    @ObservationIgnored private let health: HealthService?
    @ObservationIgnored private let reminders: ReminderScheduler?
    @ObservationIgnored private let plansReminders: Bool
    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let calendar: () -> Calendar
    @ObservationIgnored public let analytics: AnalyticsStore

    public init(
        store: NouriStore,
        transport: SyncTransport? = nil,
        health: HealthService? = nil,
        reminders: ReminderScheduler? = nil,
        plansReminders: Bool = true,
        analytics: AnalyticsStore = AnalyticsStore(),
        now: @escaping () -> Date = Date.init,
        calendar: @escaping () -> Calendar = { Calendar.autoupdatingCurrent }
    ) {
        self.store = store
        self.health = health
        self.reminders = reminders
        self.plansReminders = plansReminders
        self.now = now
        self.calendar = calendar
        self.analytics = analytics
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
        analytics.trackFirstOpenIfNeeded()
    }

    // MARK: - Lifecycle

    /// Call on launch, on foreground, and on time-zone / significant-time changes.
    public func refresh() {
        let date = now()
        today = store.summary(for: date, now: date, calendar: calendar())
        medications = store.medications()
        presets = store.presets()
        let recentWindow = DateInterval(start: date.addingTimeInterval(-14 * 86_400), end: date.addingTimeInterval(1))
        recentDrinks = FluidItem.recent(store.fluids(in: recentWindow))
        let prefs = store.preferences()
        hydrationGoal = prefs.hydrationGoalML
        calorieGoal = prefs.calorieGoal
        hydrationRemindersEnabled = prefs.hydrationRemindersEnabled
        hydrationReminderIntervalMinutes = prefs.hydrationReminderIntervalMinutes
        quietHoursStartMinutes = prefs.quietHoursStartMinutes
        quietHoursEndMinutes = prefs.quietHoursEndMinutes
        daytimeQuietEnabled = prefs.daytimeQuietEnabled
        daytimeQuietStartMinutes = prefs.daytimeQuietStartMinutes
        daytimeQuietEndMinutes = prefs.daytimeQuietEndMinutes
        hasCompletedOnboarding = prefs.hasCompletedOnboarding
        caloriesEnabled = prefs.caloriesEnabled
        appearancePreset = prefs.appearancePreset
    }

    public func refreshExternal() async {
        guard let health, let interval = calendar().dateInterval(of: .day, for: now()) else { return }
        healthConnected = health.isConnected
        imported = await health.importedTotals(in: interval)
    }

    /// Asks the paired device for recent history. The Watch calls this whenever it comes to the
    /// foreground, so anything that was still in flight shows up right away.
    /// Asks the paired device for recent records, at most once per `backfillInterval`.
    /// Records already arrive one by one via queued `transferUserInfo`; backfill only repairs gaps,
    /// so it doesn't need to wake the iPhone on every wrist raise.
    public func syncWithCounterpart() {
        let date = now()
        if let last = lastBackfillAt, date.timeIntervalSince(last) < Self.backfillInterval { return }
        lastBackfillAt = date
        sync?.requestBackfill()
    }

    public static let backfillInterval: TimeInterval = 3600
    @ObservationIgnored private var lastBackfillAt: Date?

    public var isHealthAvailable: Bool { health != nil }

    public func requestNotificationPermission() async {
        guard let reminders else { return }
        notificationsAllowed = await reminders.client.requestAuthorization()
    }

    public func connectHealth() async {
        await health?.requestAuthorization(includeEnergy: caloriesEnabled)
        await refreshExternal()
        // Entries logged before Health was connected: idempotent thanks to sync identifiers.
        if healthConnected {
            exportToHealth(store.records(updatedSince: now().addingTimeInterval(-Self.healthBackfill)))
        }
    }

    static let healthBackfill: TimeInterval = 30 * 86_400

    private var defaultSurface: LogSurface {
        #if os(watchOS)
        .watch
        #else
        .phone
        #endif
    }

    /// Both iPhone and Watch plan local reminders from their store. The Watch cannot rely on
    /// iPhone notification mirroring for an independent Watch app.
    public func rescheduleReminders() async {
        guard let reminders, plansReminders else { return }
        let date = now(), cal = calendar()
        let horizon = DateInterval(start: cal.startOfDay(for: date), duration: Double(ReminderPlanner.horizonDays + 1) * 86_400)
        let resolved = Set(store.doseLogs(around: horizon).filter { $0.value.status != .missed }.keys)
        var plan = ReminderPlanner.plan(medications: store.medications(), resolvedKeys: resolved, now: date, calendar: cal)
        let prefs = store.preferences()
        let remaining = max(0, ReminderPlanner.maxPending - plan.count)
        let hydrate = HydrationReminderPlanner.plan(
            enabled: prefs.hydrationRemindersEnabled && notificationsAllowed != false,
            intervalMinutes: prefs.hydrationReminderIntervalMinutes,
            quietStartMinutes: prefs.quietHoursStartMinutes,
            quietEndMinutes: prefs.quietHoursEndMinutes,
            daytimeQuiet: prefs.daytimeQuiet,
            todayHydrationML: store.summary(for: date, now: date, calendar: cal).hydration.value,
            goalML: prefs.hydrationGoalML,
            now: date,
            calendar: cal,
            maxCount: remaining,
            lastDrinkAt: store.lastHydratingDrink(on: date, calendar: cal)
        )
        plan.append(contentsOf: hydrate)
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

    public func summary(for day: Date) -> DaySummary {
        let date = now()
        return store.summary(for: day, now: date, calendar: calendar())
    }

    // MARK: - Entries

    /// Adds a drink. `timestamp` defaults to now; past times are allowed, future ones are clamped.
    public func addFluid(_ amountML: Double, beverage: BeverageType = .water, calories: Double? = nil, timestamp: Date? = nil,
                         surface: LogSurface? = nil) {
        guard amountML > 0 else { return }
        let date = now()
        let kcal = max(calories ?? beverage.defaultCalories(amountML: amountML), 0)
        let record = store.addFluid(amountML: amountML, beverage: beverage, calories: kcal,
                                    timestamp: min(timestamp ?? date, date), at: date)
        lastAdded = LastAdded(id: record.id, kind: .fluid(amountML: amountML, beverage: beverage))
        analytics.track("water_logged", ["surface": (surface ?? defaultSurface).rawValue])
        localChange(record)
        Task { await rescheduleReminders() }
    }

    /// Adds food. An empty name is stored as empty; views show a localized "Quick add" instead.
    public func addCalories(_ kcal: Double, name: String = "", timestamp: Date? = nil) {
        guard kcal > 0 else { return }
        let date = now()
        let record = store.addFood(name: name.trimmingCharacters(in: .whitespacesAndNewlines), calories: kcal,
                                   timestamp: min(timestamp ?? date, date), at: date)
        lastAdded = LastAdded(id: record.id, kind: .food(kcal: kcal))
        analytics.track("food_logged", ["surface": defaultSurface.rawValue])
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
        // Capture for undo before soft-delete.
        if let fluid = today.fluids.first(where: { $0.id == id }) {
            lastDeleted = LastDeleted(id: id, kind: .fluid(fluid))
        } else if let food = today.foods.first(where: { $0.id == id }) {
            lastDeleted = LastDeleted(id: id, kind: .food(food))
        }
        store.deleteEntry(id: id, at: now()).map(localChange)
        Task { await rescheduleReminders() }
    }

    public struct LastDeleted: Equatable, Sendable {
        public enum Kind: Equatable, Sendable {
            case fluid(FluidItem)
            case food(FoodItem)
        }
        public let id: UUID
        public let kind: Kind
    }

    /// Soft-deleted entry offered for undo for a few seconds by the UI.
    public private(set) var lastDeleted: LastDeleted?

    public func undoLastDelete() {
        guard let lastDeleted else { return }
        switch lastDeleted.kind {
        case .fluid(let item):
            // Re-insert as a new write with the same identity via update path after revive.
            _ = store.reviveEntry(id: item.id, at: now()).map(localChange)
        case .food(let item):
            _ = store.reviveEntry(id: item.id, at: now()).map(localChange)
        }
        self.lastDeleted = nil
        Task { await rescheduleReminders() }
    }

    public func dismissDeleteUndo(id: UUID) {
        if lastDeleted?.id == id { lastDeleted = nil }
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
        if status != nil {
            analytics.track("dose_logged", ["surface": defaultSurface.rawValue])
            await reminders?.clear(doseKey: key)
        }
        await rescheduleReminders()
    }

    public func snooze(_ dose: DoseOccurrence, minutes: Int = 10) async {
        await reminders?.snooze(dose, now: now(), minutes: minutes)
    }

    /// Handles a tap on a notification action (Taken / Skip / Snooze / hydrate amounts).
    public func handleNotificationAction(_ action: String, userInfo: [AnyHashable: Any]) async {
        if let amount = HydrationNotification.amountML(for: action) {
            addFluid(amount, surface: .notification)
            return
        }
        guard let payload = DoseNotification.payload(from: userInfo) else { return }
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

    /// Legacy entry used by tests that already have a dose payload.
    public func handleNotificationAction(_ action: String, payload: DoseNotification.Payload) async {
        await handleNotificationAction(action, userInfo: [
            "medicationID": payload.medicationID.uuidString,
            "doseKey": payload.doseKey,
            "scheduledAt": payload.scheduledAt.timeIntervalSince1970,
        ])
    }

    public func saveMedication(_ info: MedicationInfo) async {
        let isNew = !store.medications().contains { $0.id == info.id }
        store.saveMedication(info, at: now())
        if isNew { analytics.track("med_added") }
        // During onboarding the Reminders step asks, with context.
        if notificationsAllowed == nil, hasCompletedOnboarding { await requestNotificationPermission() }
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
        Task { await rescheduleReminders() }
    }

    public func setHydrationReminders(
        enabled: Bool,
        intervalMinutes: Int? = nil,
        quietStartMinutes: Int? = nil,
        quietEndMinutes: Int? = nil
    ) async {
        if enabled, notificationsAllowed != true {
            await requestNotificationPermission()
        }
        store.setHydrationReminderSettings(
            enabled: enabled,
            intervalMinutes: intervalMinutes ?? hydrationReminderIntervalMinutes,
            quietStartMinutes: quietStartMinutes ?? quietHoursStartMinutes,
            quietEndMinutes: quietEndMinutes ?? quietHoursEndMinutes,
            at: now()
        )
        settingsChanged()
        await rescheduleReminders()
    }

    public func completeOnboarding() {
        store.setOnboardingCompleted(true, at: now())
        analytics.track("onboarding_done")
        settingsChanged()
    }

    public func setDaytimeQuiet(enabled: Bool? = nil, startMinutes: Int? = nil, endMinutes: Int? = nil) async {
        store.setDaytimeQuiet(enabled: enabled ?? daytimeQuietEnabled,
                              startMinutes: startMinutes ?? daytimeQuietStartMinutes,
                              endMinutes: endMinutes ?? daytimeQuietEndMinutes, at: now())
        refresh()
        await rescheduleReminders()
    }

    public func setCaloriesEnabled(_ enabled: Bool) {
        store.setCaloriesEnabled(enabled, at: now())
        settingsChanged()
    }

    public func setAppearancePreset(_ preset: AppearancePreset) {
        store.setAppearancePreset(preset, at: now())
        settingsChanged()
    }

    public func exportAnalyticsJSON() throws -> Data {
        try analytics.exportJSON()
    }

    public var pendingMedicationsDeepLink = false

    public func dismissError() { lastErrorMessage = nil }

    /// Soft-deletes all user data, resets prefs, clears notifications, optionally HealthKit samples.
    public func deleteAllData(removeFromHealth: Bool) async {
        let date = now()
        let result = store.deleteAllData(at: date)
        lastAdded = nil
        lastDeleted = nil
        for record in result.records {
            sync?.publish(record)
        }
        sync?.publishSettings()
        if removeFromHealth, let health {
            // Delete energy samples too, even if calories are hidden now: earlier builds may have written them.
            for record in result.records { await health.export(record, includeEnergy: true) }
        }
        await reminders?.clearAllManaged()
        didChange()
        await rescheduleReminders()
    }

    public func exportDataJSON() throws -> Data {
        try store.exportJSON(calendar: calendar(), now: now())
    }

    public func hydrationStats(days: Int = 7) -> HydrationStats {
        HydrationStats.build(days: history(days: days), calendar: calendar())
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
        let includeEnergy = caloriesEnabled
        Task {
            for record in records {
                if !includeEnergy, case .food = record { continue }
                await health.export(record, includeEnergy: includeEnergy)
            }
        }
    }

    private func didChange() {
        refresh()
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
