import Foundation
import SwiftData
import Testing
@testable import NouriKit

@Suite struct QuickAddPresetsDomainTests {
    @Test func validation() {
        let amounts = [100, 250, 500]
        #expect(QuickAddPresets.problem(adding: 330, to: amounts) == nil)
        #expect(QuickAddPresets.problem(adding: 0, to: amounts) == .outOfRange)
        #expect(QuickAddPresets.problem(adding: -50, to: amounts) == .outOfRange)
        #expect(QuickAddPresets.problem(adding: 2001, to: amounts) == .outOfRange)
        #expect(QuickAddPresets.problem(adding: 250, to: amounts) == .duplicate)
        #expect(QuickAddPresets.problem(adding: 250, to: amounts, at: 1) == nil)  // unchanged edit
        #expect(QuickAddPresets.problem(adding: 500, to: amounts, at: 1) == .duplicate)
        #expect(QuickAddPresets.problem(adding: 750, to: amounts + [330]) == .full)
        #expect(QuickAddPresets.problem(adding: 750, to: amounts + [330], at: 0) == nil)
    }

    @Test func sanitizingAndDecoding() {
        #expect(QuickAddPresets.sanitized([]) == QuickAddPresets.defaults)
        #expect(QuickAddPresets.sanitized([0, -1, 9999]) == QuickAddPresets.defaults)
        #expect(QuickAddPresets.sanitized([500, 500, 0, 200, 300, 400, 600]) == [500, 200, 300, 400])
        #expect(QuickAddPresets.decode("") == QuickAddPresets.defaults)
        #expect(QuickAddPresets.decode("330,x,150") == [330, 150])
        #expect(QuickAddPresets.decode(QuickAddPresets.encode([750, 50])) == [750, 50])
    }
}

@MainActor
@Suite struct QuickAddPresetsStoreTests {
    let now = date(2026, 9, 16, 12)

    @Test func defaultsForNewAndExistingPreferences() {
        #expect(makeStore().preferences().quickAddAmounts == [100, 250, 500])
        let model = AppModel(store: makeStore(), now: { date(2026, 9, 16, 12) }, calendar: { calendar() })
        #expect(model.quickAddAmounts == [100, 250, 500])
    }

    @Test func survivesRelaunch() throws {
        let url = FileManager.default.temporaryDirectory.appending(path: "nouri-\(UUID()).store")
        defer { try? FileManager.default.removeItem(at: url) }
        func open() throws -> NouriStore {
            let schema = Schema([FluidEntry.self, FoodEntry.self, Medication.self, MedicationLog.self,
                                 CaloriePreset.self, UserPreferences.self])
            return NouriStore(container: try ModelContainer(for: schema, configurations: ModelConfiguration(schema: schema, url: url)))
        }
        try open().setQuickAddAmounts([330, 150], at: now)
        #expect(try open().preferences().quickAddAmounts == [330, 150])
    }

    @Test func deleteAllRestoresDefaults() {
        let store = makeStore()
        store.setQuickAddAmounts([330], at: now)
        _ = store.deleteAllData(at: now.addingTimeInterval(1))
        #expect(store.preferences().quickAddAmounts == QuickAddPresets.defaults)
    }
}

@MainActor
@Suite struct QuickAddPresetsModelTests {
    let cal = calendar()

    func pair(_ clock: TestClock) -> (phone: AppModel, watch: AppModel, watchT: LoopbackTransport) {
        let cal = self.cal
        let (a, b) = LoopbackTransport.pair()
        return (AppModel(store: makeStore(), transport: a, now: { clock.now }, calendar: { cal }),
                AppModel(store: makeStore(), transport: b, now: { clock.now }, calendar: { cal }), b)
    }

    @Test func addEditRemoveReorder() {
        let clock = TestClock(date(2026, 9, 16, 9))
        let model = pair(clock).phone
        #expect(model.addQuickAddAmount(330) == nil)
        #expect(model.addQuickAddAmount(750) == .full)
        #expect(model.addQuickAddAmount(0) == .outOfRange)
        #expect(model.quickAddAmounts == [100, 250, 500, 330])

        #expect(model.updateQuickAddAmount(at: 0, to: 250) == .duplicate)
        #expect(model.updateQuickAddAmount(at: 0, to: 150) == nil)
        model.moveQuickAddAmounts(from: [3], to: 0)
        #expect(model.quickAddAmounts == [330, 150, 250, 500])

        model.removeQuickAddAmounts(at: [1, 2, 3])
        #expect(model.quickAddAmounts == [330])
        model.removeQuickAddAmounts(at: [0])  // the last one stays
        #expect(model.quickAddAmounts == [330])
    }

    @Test func presetsReachWatchAndLatestWins() {
        let clock = TestClock(date(2026, 9, 16, 9))
        let p = pair(clock)
        p.phone.addQuickAddAmount(330)
        #expect(p.watch.quickAddAmounts == [100, 250, 500, 330])

        // Watch offline: it keeps logging with the old buttons, then catches up.
        p.watchT.peer?.isOnline = false
        clock.advance(minutes: 1)
        p.phone.removeQuickAddAmounts(at: [0])
        clock.advance(minutes: 1)
        p.phone.updateQuickAddAmount(at: 0, to: 200)
        p.watch.addFluid(Double(p.watch.quickAddAmounts[0]))
        #expect(p.watch.quickAddAmounts == [100, 250, 500, 330])
        p.watchT.peer?.flush()
        #expect(p.watch.quickAddAmounts == [200, 500, 330])
        #expect(p.phone.today.hydration.value == 100)
        #expect(p.watch.today.hydration.value == 100)
    }

    @Test func snapshotFromOlderPhoneKeepsWatchPresets() throws {
        let watch = makeStore()
        watch.setQuickAddAmounts([330], at: date(2026, 9, 16, 9))
        var snapshot = makeStore().snapshot()
        snapshot.goalsUpdatedAt = date(2026, 9, 16, 10)
        snapshot.hydrationGoalML = 3000
        // Old builds don't send the key at all.
        var json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(snapshot)) as! [String: Any]
        json["quickAddAmounts"] = nil
        let legacy = try JSONDecoder().decode(SettingsSnapshot.self, from: JSONSerialization.data(withJSONObject: json))
        #expect(legacy.quickAddAmounts == nil)
        watch.apply(legacy)
        #expect(watch.preferences().hydrationGoalML == 3000)
        #expect(watch.preferences().quickAddAmounts == [330])
    }

    @Test func quickAddUsesConfiguredAmountThroughPipeline() {
        let clock = TestClock(date(2026, 9, 16, 9))
        let cal = self.cal
        let health = FakeHealth()
        let (a, b) = LoopbackTransport.pair()
        let phone = AppModel(store: makeStore(), transport: a, health: health, now: { clock.now }, calendar: { cal })
        let watch = AppModel(store: makeStore(), transport: b, now: { clock.now }, calendar: { cal })
        phone.updateQuickAddAmount(at: 0, to: 330)
        watch.addFluid(Double(watch.quickAddAmounts[0]))
        #expect(watch.today.fluids.map(\.amountML) == [330])
        #expect(phone.today.hydration.value == 330)
        #expect(watch.lastAdded.map { $0.kind } == .fluid(amountML: 330, beverage: .water))
    }
}
