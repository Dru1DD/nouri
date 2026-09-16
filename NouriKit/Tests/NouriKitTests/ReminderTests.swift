import Foundation
import Testing
@testable import NouriKit

@Suite struct ReminderPlannerTests {
    let cal = calendar()

    @Test func plansOnlyFutureUnresolvedDoses() {
        let m = med("Vitamin D", [(8, 0), (20, 0)])
        let now = date(2026, 9, 16, 12)
        let tonight = m.occurrences(on: now, calendar: cal)[1]
        let plan = ReminderPlanner.plan(medications: [m], resolvedKeys: [tonight.key], now: now, calendar: cal, horizonDays: 2)
        // Today 08:00 is past, today 20:00 already taken → only tomorrow's two doses.
        #expect(plan.map(\.fireDate) == [date(2026, 9, 17, 8), date(2026, 9, 17, 20)])
        #expect(plan.allSatisfy { $0.id.hasPrefix(ReminderPlanner.dosePrefix) })
        #expect(plan[0].title == "💊 Time to take Vitamin D")
    }

    @Test func identifiersAreDeterministic() {
        let m = med("X", [(8, 0)])
        let now = date(2026, 9, 16, 6)
        let a = ReminderPlanner.plan(medications: [m], resolvedKeys: [], now: now, calendar: cal)
        let b = ReminderPlanner.plan(medications: [m], resolvedKeys: [], now: now.addingTimeInterval(60), calendar: cal)
        #expect(a.map(\.id) == b.map(\.id))
    }

    @Test func respectsPendingLimit() {
        let meds = (0..<10).map { med("M\($0)", [(8, 0), (12, 0), (20, 0)]) }
        let plan = ReminderPlanner.plan(medications: meds, resolvedKeys: [], now: date(2026, 9, 16, 6), calendar: cal)
        #expect(plan.count == ReminderPlanner.maxPending)
        #expect(plan.map(\.fireDate) == plan.map(\.fireDate).sorted())
    }

    @Test func weekdayScheduleOverHorizon() {
        let m = med("X", [(9, 0)], weekdays: [2])  // Mondays
        let plan = ReminderPlanner.plan(medications: [m], resolvedKeys: [], now: date(2026, 9, 16), calendar: cal)
        #expect(plan.count == 2)
        #expect(plan.allSatisfy { cal.component(.weekday, from: $0.fireDate) == 2 })
    }

    @Test func acrossDSTTransitionKeepsWallClock() {
        let ny = calendar("America/New_York")
        let plan = ReminderPlanner.plan(medications: [med("X", [(8, 0)])], resolvedKeys: [],
                                        now: date(2026, 3, 7, 7, in: ny), calendar: ny, horizonDays: 2)
        #expect(plan.count == 2)
        #expect(plan.allSatisfy { ny.component(.hour, from: $0.fireDate) == 8 })
        #expect(plan[1].fireDate.timeIntervalSince(plan[0].fireDate) == 23 * 3600)
    }

    @Test func snoozeFiresLaterWithSeparateIdentifier() {
        let dose = med("X", [(8, 0)]).occurrences(on: date(2026, 9, 16), calendar: cal)[0]
        let now = date(2026, 9, 16, 8, 1)
        let r = ReminderPlanner.snooze(dose, now: now, minutes: 10)
        #expect(r.id == ReminderPlanner.snoozePrefix + dose.key)
        #expect(r.fireDate == date(2026, 9, 16, 8, 11))
        #expect(r.scheduledAt == dose.scheduledAt)
    }

    @Test func notificationPayloadRoundTrip() {
        let dose = med("X", [(8, 0)]).occurrences(on: date(2026, 9, 16), calendar: cal)[0]
        let r = ReminderPlanner.snooze(dose, now: .now)
        let payload = DoseNotification.payload(from: DoseNotification.userInfo(for: r))
        #expect(payload?.doseKey == dose.key)
        #expect(payload?.medicationID == dose.medicationID)
        #expect(payload?.scheduledAt == dose.scheduledAt)
        #expect(DoseNotification.payload(from: ["foo": "bar"]) == nil)
    }
}

@MainActor
@Suite struct ReminderSchedulerTests {
    let cal = calendar()

    @Test func applyIsIdempotentAndRemovesStale() async {
        let client = InMemoryNotificationClient()
        let scheduler = ReminderScheduler(client: client)
        let now = date(2026, 9, 16, 6)
        let a = med("A", [(8, 0)]), b = med("B", [(9, 0)])

        await scheduler.apply(ReminderPlanner.plan(medications: [a, b], resolvedKeys: [], now: now, calendar: cal))
        await scheduler.apply(ReminderPlanner.plan(medications: [a, b], resolvedKeys: [], now: now, calendar: cal))
        #expect(await client.pending.count == 28)

        // B deleted → its reminders disappear; snoozes are left alone.
        let dose = a.occurrences(on: now, calendar: cal)[0]
        await scheduler.snooze(dose, now: now)
        await scheduler.apply(ReminderPlanner.plan(medications: [a], resolvedKeys: [], now: now, calendar: cal))
        let pending = await client.pending
        #expect(pending.count == 15)
        #expect(pending.values.filter { $0.medicationID == b.id }.isEmpty)
        #expect(pending[ReminderPlanner.snoozePrefix + dose.key] != nil)
    }

    @Test func clearRemovesDoseAndSnooze() async {
        let client = InMemoryNotificationClient()
        let scheduler = ReminderScheduler(client: client)
        let now = date(2026, 9, 16, 6)
        let dose = med("A", [(8, 0)]).occurrences(on: now, calendar: cal)[0]
        await scheduler.apply([ReminderPlanner.reminder(for: dose, id: ReminderPlanner.dosePrefix + dose.key, fireDate: dose.scheduledAt)])
        await scheduler.snooze(dose, now: now)
        #expect(await client.pending.count == 2)
        await scheduler.clear(doseKey: dose.key)
        #expect(await client.pending.isEmpty)
    }
}
