import Foundation
import Testing
@testable import NouriKit

@MainActor
@Suite struct StoreTests {
    let cal = calendar()
    let now = date(2026, 9, 16, 12)

    @Test func addAndSoftDeleteEntries() {
        let store = makeStore()
        guard case .fluid(let water) = store.addFluid(amountML: 250, beverage: .water, calories: 0, at: now) else {
            Issue.record("expected fluid record"); return
        }
        _ = store.addFood(name: "Lunch", calories: 650, at: now)
        #expect(store.summary(for: now, now: now, calendar: cal).hydration.value == 250)

        let deletion = store.deleteEntry(id: water.id, at: now.addingTimeInterval(1))
        #expect(deletion != nil)
        let s = store.summary(for: now, now: now, calendar: cal)
        #expect(s.hydration.value == 0)
        #expect(s.calories.value == 650)
        #expect(store.deleteEntry(id: UUID(), at: now) == nil)
    }

    @Test func presetsAndGoals() {
        let store = makeStore()
        store.addPreset(name: "Protein shake", calories: 250, at: now)
        store.addPreset(name: "Breakfast", calories: 450, at: now)
        #expect(store.presets().map(\.name) == ["Breakfast", "Protein shake"])
        store.deletePreset(id: store.presets()[0].id, at: now)
        #expect(store.presets().map(\.name) == ["Protein shake"])

        store.setGoals(hydrationML: 3000, calories: 1800, at: now)
        let s = store.summary(for: now, now: now, calendar: cal)
        #expect(s.hydration.goal == 3000)
        #expect(s.calories.goal == 1800)
    }

    @Test func doseTakenSkippedAndUndo() {
        let store = makeStore()
        let m = med("Vitamin D", [(8, 0)])
        store.saveMedication(m, at: now)
        let dose = m.occurrences(on: now, calendar: cal)[0]

        _ = store.logDose(key: dose.key, medicationID: m.id, scheduledAt: dose.scheduledAt, status: .taken, at: now)
        #expect(store.summary(for: now, now: now, calendar: cal).doses[0].status == .taken)

        _ = store.logDose(key: dose.key, medicationID: m.id, scheduledAt: dose.scheduledAt, status: .skipped, at: now)
        #expect(store.summary(for: now, now: now, calendar: cal).doses[0].status == .skipped)

        _ = store.logDose(key: dose.key, medicationID: m.id, scheduledAt: dose.scheduledAt, status: nil, at: now)
        #expect(store.summary(for: now, now: now, calendar: cal).doses[0].status == .missed)
    }

    @Test func applyingTheSameRecordTwiceIsANoOp() {
        let store = makeStore()
        let record = SyncRecord.fluid(FluidRecord(id: UUID(), amountML: 250, beverage: .water, calories: 0,
                                                   timestamp: now, updatedAt: now))
        #expect(store.apply(record))
        #expect(!store.apply(record))
        #expect(store.summary(for: now, now: now, calendar: cal).fluids.count == 1)
    }

    @Test func lastWriterWinsOnConflicts() {
        let store = makeStore()
        let id = UUID()
        let newer = FoodRecord(id: id, name: "Lunch", calories: 700, timestamp: now, updatedAt: now.addingTimeInterval(10))
        let older = FoodRecord(id: id, name: "Lunch", calories: 500, timestamp: now, updatedAt: now)
        #expect(store.apply(.food(newer)))
        #expect(!store.apply(.food(older)))  // late, stale delivery must not win
        #expect(store.summary(for: now, now: now, calendar: cal).calories.value == 700)
    }

    @Test func deletionIsNotResurrectedByStaleUpsert() {
        let store = makeStore()
        let id = UUID()
        let created = FluidRecord(id: id, amountML: 250, beverage: .water, calories: 0, timestamp: now, updatedAt: now)
        var deleted = created
        deleted.updatedAt = now.addingTimeInterval(5)
        deleted.deletedAt = deleted.updatedAt
        store.apply(.fluid(deleted))
        store.apply(.fluid(created))
        #expect(store.summary(for: now, now: now, calendar: cal).hydration.value == 0)
    }

    @Test func doseLogsFromTwoDevicesConvergeOnOneLog() {
        let store = makeStore()
        let m = med("X", [(8, 0)])
        let dose = m.occurrences(on: now, calendar: cal)[0]
        let phone = DoseRecord(id: UUID(), medicationID: m.id, doseKey: dose.key, scheduledTime: dose.scheduledAt,
                               takenAt: now, status: .taken, updatedAt: now)
        let watch = DoseRecord(id: UUID(), medicationID: m.id, doseKey: dose.key, scheduledTime: dose.scheduledAt,
                               takenAt: now, status: .skipped, updatedAt: now.addingTimeInterval(1))
        store.apply(.dose(phone))
        store.apply(.dose(watch))
        let doses = store.records(updatedSince: .distantPast).compactMap { r -> DoseRecord? in
            if case .dose(let d) = r { d } else { nil }
        }
        #expect(doses.count == 1)
        #expect(doses[0].status == .skipped)
        #expect(doses[0].id == phone.id)
    }
}

@MainActor
@Suite struct SyncTests {
    let cal = calendar()
    let now = date(2026, 9, 16, 12)

    func pair() -> (phone: NouriStore, watch: NouriStore, phoneT: LoopbackTransport, watchT: LoopbackTransport,
                    phoneSync: SyncEngine, watchSync: SyncEngine) {
        let (pt, wt) = LoopbackTransport.pair()
        let phone = makeStore(), watch = makeStore()
        let now = self.now
        return (phone, watch, pt, wt,
                SyncEngine(store: phone, transport: pt, now: { now }),
                SyncEngine(store: watch, transport: wt, now: { now }))
    }

    @Test func watchEntryReachesPhone() {
        let p = pair()
        p.watchSync.publish(p.watch.addFluid(amountML: 250, beverage: .water, calories: 0, at: now))
        #expect(p.phone.summary(for: now, now: now, calendar: cal).hydration.value == 250)
    }

    @Test func offlineEventsDeliverLaterInOrder() {
        let p = pair()
        p.watchT.isOnline = false
        let add = p.watch.addFluid(amountML: 500, beverage: .water, calories: 0, at: now)
        p.watchSync.publish(add)
        guard case .fluid(let r) = add, let del = p.watch.deleteEntry(id: r.id, at: now.addingTimeInterval(1)) else {
            Issue.record("unexpected"); return
        }
        p.watchSync.publish(p.watch.addFluid(amountML: 100, beverage: .tea, calories: 1, at: now))
        p.watchSync.publish(del)
        #expect(p.phone.summary(for: now, now: now, calendar: cal).fluids.isEmpty)

        p.watchT.flush()
        #expect(p.phone.summary(for: now, now: now, calendar: cal).hydration.value == 100)
    }

    @Test func duplicateDeliveryDoesNotDuplicate() {
        let p = pair()
        let record = p.watch.addFood(name: "Quick add", calories: 250, at: now)
        var changes = 0
        p.phoneSync.onRemoteChange = { _ in changes += 1 }
        p.watchSync.publish(record)
        p.watchSync.publish(record)
        p.watchSync.publish(record)
        #expect(p.phone.summary(for: now, now: now, calendar: cal).foods.count == 1)
        #expect(changes == 1)
    }

    @Test func conflictingDoseEventsConvergeOnBothDevices() {
        let p = pair()
        let m = med("X", [(8, 0)])
        p.phone.saveMedication(m, at: now)
        p.phoneSync.publishSettings()
        let dose = m.occurrences(on: now, calendar: cal)[0]

        // Both devices offline, both log the same dose; the later action wins everywhere.
        p.phoneT.isOnline = false
        p.watchT.isOnline = false
        p.phoneSync.publish(p.phone.logDose(key: dose.key, medicationID: m.id, scheduledAt: dose.scheduledAt, status: .taken, at: now))
        p.watchSync.publish(p.watch.logDose(key: dose.key, medicationID: m.id, scheduledAt: dose.scheduledAt,
                                            status: .skipped, at: now.addingTimeInterval(30)))
        p.phoneT.flush()
        p.watchT.flush()
        #expect(p.phone.summary(for: now, now: now, calendar: cal).doses.map(\.status) == [.skipped])
        #expect(p.watch.summary(for: now, now: now, calendar: cal).doses.map(\.status) == [.skipped])
    }

    @Test func settingsSnapshotMirrorsMedicationsGoalsAndDeletions() {
        let p = pair()
        let a = med("A", [(8, 0)]), b = med("B", [(9, 0)])
        p.phone.saveMedication(a, at: now)
        p.phone.saveMedication(b, at: now)
        p.phone.addPreset(name: "Breakfast", calories: 450, at: now)
        p.phone.setGoals(hydrationML: 3000, calories: 1800, at: now)
        p.phoneSync.publishSettings()
        #expect(p.watch.medications().map(\.name) == ["A", "B"])
        #expect(p.watch.presets().map(\.name) == ["Breakfast"])
        #expect(p.watch.preferences().hydrationGoalML == 3000)

        p.phone.deleteMedication(id: b.id, at: now.addingTimeInterval(1))
        p.phoneSync.publishSettings()
        p.phoneSync.publishSettings()
        #expect(p.watch.medications().map(\.name) == ["A"])
    }

    @Test func backfillSendsRecentHistoryAndSettings() {
        let p = pair()
        _ = p.phone.addFluid(amountML: 250, beverage: .water, calories: 0, at: now)
        _ = p.phone.addFluid(amountML: 999, beverage: .water, calories: 0, at: now.addingTimeInterval(-10 * 86_400))
        p.phone.saveMedication(med("A", [(8, 0)]), at: now)
        p.watchSync.requestBackfill()
        #expect(p.watch.summary(for: now, now: now, calendar: cal).hydration.value == 250)
        #expect(p.watch.records(updatedSince: .distantPast).count == 1)
        #expect(p.watch.medications().count == 1)
    }
}

@MainActor
@Suite struct AppModelTests {
    let cal = calendar()

    func makeModel(clock: TestClock, client: InMemoryNotificationClient = InMemoryNotificationClient()) -> AppModel {
        let cal = self.cal
        return AppModel(store: makeStore(), reminders: ReminderScheduler(client: client),
                        now: { clock.now }, calendar: { cal })
    }

    @Test func quickAddsUpdateToday() {
        let model = makeModel(clock: TestClock(date(2026, 9, 16, 9)))
        model.addFluid(250)
        model.addFluid(300, beverage: .coffee)
        model.addFluid(0)
        model.addCalories(500)
        model.addCalories(-5)
        #expect(model.today.hydration.value == 550)
        #expect(model.today.calories.value == 503)
        #expect(model.today.activity.count == 3)
    }

    @Test func creatingMedicationSchedulesReminders() async {
        let client = InMemoryNotificationClient()
        let model = makeModel(clock: TestClock(date(2026, 9, 16, 9)), client: client)
        await model.saveMedication(med("Vitamin D", [(8, 0), (20, 0)]))
        // Today 20:00 + 13 more days × 2.
        #expect(model.scheduledReminderCount == 27)
        #expect(await client.pending.count == 27)
        await model.rescheduleReminders()
        #expect(await client.pending.count == 27)
    }

    @Test func notificationActionsTakenSkipSnooze() async {
        let clock = TestClock(date(2026, 9, 16, 7))
        let client = InMemoryNotificationClient()
        let model = makeModel(clock: clock, client: client)
        let m = med("Vitamin D", [(8, 0), (20, 0)])
        await model.saveMedication(m)
        clock.advance(minutes: 61)  // 08:01, morning reminder delivered
        await model.rescheduleReminders()
        let morning = model.today.doses[0].occurrence
        let evening = model.today.doses[1].occurrence
        let payload = { (d: DoseOccurrence) in DoseNotification.Payload(medicationID: d.medicationID, doseKey: d.key, scheduledAt: d.scheduledAt) }

        await model.handleNotificationAction(DoseNotification.snoozeAction, payload: payload(morning))
        #expect(await client.pending[ReminderPlanner.snoozePrefix + morning.key]?.fireDate == clock.now.addingTimeInterval(600))
        #expect(model.today.doses[0].status == .due)

        await model.handleNotificationAction(DoseNotification.takenAction, payload: payload(morning))
        #expect(model.today.doses[0].status == .taken)
        #expect(await client.pending[ReminderPlanner.snoozePrefix + morning.key] == nil)

        // Skipping tonight's dose early removes its pending reminder.
        #expect(await client.pending[ReminderPlanner.dosePrefix + evening.key] != nil)
        await model.handleNotificationAction(DoseNotification.skipAction, payload: payload(evening))
        #expect(model.today.doses[1].status == .skipped)
        #expect(await client.pending[ReminderPlanner.dosePrefix + evening.key] == nil)
        #expect(model.today.dosesTaken == 1)
    }

    @Test func undoRestoresReminder() async {
        let clock = TestClock(date(2026, 9, 16, 7))
        let client = InMemoryNotificationClient()
        let model = makeModel(clock: clock, client: client)
        await model.saveMedication(med("X", [(20, 0)]))
        let dose = model.today.doses[0].occurrence
        await model.setDose(dose, status: .taken)
        #expect(await client.pending[ReminderPlanner.dosePrefix + dose.key] == nil)
        await model.setDose(dose, status: nil)
        #expect(await client.pending[ReminderPlanner.dosePrefix + dose.key] != nil)
        #expect(model.today.doses[0].status == .upcoming)
    }

    @Test func todayRollsOverAtMidnight() {
        let clock = TestClock(date(2026, 9, 16, 23, 50))
        let model = makeModel(clock: clock)
        model.addFluid(250)
        clock.advance(minutes: 20)
        model.refresh()
        #expect(model.today.hydration.value == 0)
        #expect(model.history(days: 2).map(\.hydration.value) == [0, 250])
    }
}

@MainActor
@Suite struct LocalEditTests {
    @Test func editsAtTheSameInstantStillApply() {
        let store = makeStore()
        let now = date(2026, 9, 16, 12)
        var m = med("Vitamin D", [(8, 0)])
        store.saveMedication(m, at: now)
        m.name = "Vitamin D3"
        store.saveMedication(m, at: now)
        #expect(store.medications().map(\.name) == ["Vitamin D3"])
        store.setGoals(hydrationML: 3000, calories: 1, at: .distantPast)
        store.setGoals(hydrationML: 3100, calories: 1, at: .distantPast)
        #expect(store.preferences().hydrationGoalML == 3100)
    }
}

@MainActor
@Suite struct WatchNotificationTests {
    let cal = calendar()

    /// Watch configuration: handles actions and snoozes, but never plans dose reminders itself.
    @Test func watchHandlesActionsWithoutPlanningReminders() async {
        let clock = TestClock(date(2026, 9, 16, 8, 1))
        let client = InMemoryNotificationClient()
        let cal = self.cal
        let (phoneT, watchT) = LoopbackTransport.pair()
        let phoneClient = InMemoryNotificationClient()
        let phone = AppModel(store: makeStore(), transport: phoneT, reminders: ReminderScheduler(client: phoneClient),
                             now: { clock.now }, calendar: { cal })
        let watch = AppModel(store: makeStore(), transport: watchT, reminders: ReminderScheduler(client: client),
                             plansReminders: false, now: { clock.now }, calendar: { cal })

        let m = med("Vitamin D", [(8, 0), (20, 0)])
        await phone.saveMedication(m)
        #expect(watch.medications.map(\.name) == ["Vitamin D"])
        #expect(await client.pending.isEmpty)

        let morning = watch.today.doses[0].occurrence
        let payload = DoseNotification.Payload(medicationID: morning.medicationID, doseKey: morning.key,
                                               scheduledAt: morning.scheduledAt)
        await watch.handleNotificationAction(DoseNotification.snoozeAction, payload: payload)
        #expect(await client.pending.keys.sorted() == [ReminderPlanner.snoozePrefix + morning.key])

        // Pretend the phone already delivered/kept a snooze for this dose.
        await phoneClient.add(ReminderPlanner.snooze(morning, now: clock.now))
        await watch.handleNotificationAction(DoseNotification.takenAction, payload: payload)
        #expect(await client.pending.isEmpty)
        #expect(phone.today.doses[0].status == .taken)

        // Phone cleans up the resolved dose asynchronously.
        for _ in 0..<50 where await phoneClient.pending[ReminderPlanner.snoozePrefix + morning.key] != nil {
            await Task.yield()
        }
        #expect(await phoneClient.pending[ReminderPlanner.snoozePrefix + morning.key] == nil)
        #expect(await phoneClient.pending[ReminderPlanner.dosePrefix + watch.today.doses[1].occurrence.key] != nil)
    }
}

@MainActor
@Suite struct EntryEditingTests {
    let cal = calendar()

    func model(_ clock: TestClock) -> AppModel {
        let cal = self.cal
        return AppModel(store: makeStore(), now: { clock.now }, calendar: { cal })
    }

    @Test func undoRemovesOnlyTheLastQuickAdd() {
        let model = model(TestClock(date(2026, 9, 16, 9)))
        model.addFluid(250)
        model.addFluid(500)
        #expect(model.lastAdded?.kind == .fluid(amountML: 500, beverage: .water))
        model.undoLastAdd()
        #expect(model.today.hydration.value == 250)
        #expect(model.lastAdded == nil)
        model.undoLastAdd()  // nothing left to undo
        #expect(model.today.hydration.value == 250)
    }

    @Test func dismissIgnoresStaleIDs() {
        let model = model(TestClock(date(2026, 9, 16, 9)))
        model.addCalories(100)
        let first = model.lastAdded?.id
        model.addCalories(250, name: "Snack")
        model.dismissUndo(id: first!)
        #expect(model.lastAdded?.kind == .food(kcal: 250))
    }

    @Test func backdatedEntriesLandOnTheirDayAndFutureIsClamped() {
        let clock = TestClock(date(2026, 9, 16, 9))
        let model = model(clock)
        model.addFluid(300, timestamp: date(2026, 9, 15, 22))
        model.addCalories(400, timestamp: date(2026, 9, 16, 7))
        model.addFluid(100, timestamp: date(2026, 9, 16, 18))
        #expect(model.today.hydration.value == 100)
        #expect(model.today.fluids.map(\.timestamp) == [clock.now])
        #expect(model.today.foods.map(\.timestamp) == [date(2026, 9, 16, 7)])
        #expect(model.history(days: 2).map(\.hydration.value) == [100, 300])
    }

    @Test func editingUpdatesAmountTimeAndSyncs() {
        let clock = TestClock(date(2026, 9, 16, 9))
        let cal = self.cal
        let (a, b) = LoopbackTransport.pair()
        let phone = AppModel(store: makeStore(), transport: a, now: { clock.now }, calendar: { cal })
        let watch = AppModel(store: makeStore(), transport: b, now: { clock.now }, calendar: { cal })
        watch.addFluid(250)
        clock.advance(minutes: 1)
        var drink = phone.today.fluids[0]
        drink.amountML = 330
        drink.beverage = .softDrink
        drink.calories = 139
        drink.timestamp = date(2026, 9, 16, 8)
        phone.updateFluid(drink)
        #expect(watch.today.fluids == [drink])
        #expect(watch.today.calories.value == 139)

        watch.addCalories(500)
        clock.advance(minutes: 1)
        var food = phone.today.foods[0]
        food.name = "  Lunch "
        phone.updateFood(food)
        #expect(watch.today.foods[0].name == "Lunch")
    }
}
