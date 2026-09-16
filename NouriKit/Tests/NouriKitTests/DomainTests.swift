import Foundation
import Testing
@testable import NouriKit

@Suite struct HydrationAndCalorieTests {
    let cal = calendar()
    let day = date(2026, 9, 16, 12)

    func summary(fluids: [FluidItem] = [], foods: [FoodItem] = [], goalML: Double = 2500, goalKcal: Double = 2000) -> DaySummary {
        DaySummary.build(day: day, fluids: fluids, foods: foods, medications: [], logs: [:],
                         hydrationGoalML: goalML, calorieGoal: goalKcal, now: day, calendar: cal)
    }

    @Test func dailyWaterTotalAndPercent() {
        let s = summary(fluids: [
            FluidItem(amountML: 250, beverage: .water, calories: 0, timestamp: date(2026, 9, 16, 9)),
            FluidItem(amountML: 1400, beverage: .water, calories: 0, timestamp: date(2026, 9, 16, 10)),
        ])
        #expect(s.hydration.value == 1650)
        #expect(s.hydration.percent == 66)
        #expect(abs(s.hydration.fraction - 0.66) < 0.0001)
    }

    @Test func progressClampsButPercentShowsOvershoot() {
        let p = GoalProgress(value: 3000, goal: 2500)
        #expect(p.fraction == 1)
        #expect(p.percent == 120)
    }

    @Test func zeroGoalIsSafe() {
        let p = GoalProgress(value: 500, goal: 0)
        #expect(p.fraction == 0)
        #expect(p.percent == 0)
    }

    @Test func beverageCaloriesCountTowardsCalories() {
        let s = summary(
            fluids: [
                FluidItem(amountML: 330, beverage: .softDrink, calories: BeverageType.softDrink.defaultCalories(amountML: 330), timestamp: day),
                FluidItem(amountML: 300, beverage: .coffee, calories: 3, timestamp: day),
            ],
            foods: [FoodItem(name: "Lunch", calories: 650, timestamp: day)]
        )
        #expect(s.hydration.value == 630)
        #expect(s.beverageCalories == 139 + 3)
        #expect(s.calories.value == 650 + 142)
    }

    @Test func beverageDefaults() {
        #expect(BeverageType.water.defaultCalories(amountML: 500) == 0)
        #expect(BeverageType.coffee.defaultCalories(amountML: 300) == 3)
        #expect(BeverageType.tea.defaultCalories(amountML: 250) == 3)
        #expect(BeverageType.softDrink.defaultCalories(amountML: 330) == 139)
        #expect(BeverageType.other.defaultCalories(amountML: 250) == 0)
    }

    @Test func calorieTotalsAndGoal() {
        let s = summary(foods: [
            FoodItem(name: "Breakfast", calories: 450, timestamp: date(2026, 9, 16, 8)),
            FoodItem(name: "Quick add", calories: 500, timestamp: date(2026, 9, 16, 11)),
        ], goalKcal: 2000)
        #expect(s.calories.value == 950)
        #expect(s.calories.percent == 47)
    }

    @Test func midnightBoundariesAndOtherDaysExcluded() {
        let s = summary(
            fluids: [
                FluidItem(amountML: 1, beverage: .water, calories: 0, timestamp: date(2026, 9, 15, 23, 59)),
                FluidItem(amountML: 10, beverage: .water, calories: 0, timestamp: date(2026, 9, 16, 0, 0)),
                FluidItem(amountML: 100, beverage: .water, calories: 0, timestamp: date(2026, 9, 16, 23, 59)),
                FluidItem(amountML: 1000, beverage: .water, calories: 0, timestamp: date(2026, 9, 17, 0, 0)),
            ]
        )
        #expect(s.hydration.value == 110)
    }

    @Test func dayBoundariesFollowTheCalendarTimeZone() {
        // 23:30 in Kyiv is 21:30 in London: the same instant belongs to the 16th in both,
        // but 00:30 Kyiv on the 17th is still the 16th in London.
        let instant = date(2026, 9, 17, 0, 30, in: calendar("Europe/Kyiv"))
        let fluid = FluidItem(amountML: 250, beverage: .water, calories: 0, timestamp: instant)
        let london = DaySummary.build(day: date(2026, 9, 16, 12, in: calendar("Europe/London")), fluids: [fluid], foods: [],
                                      medications: [], logs: [:], hydrationGoalML: 1, calorieGoal: 1,
                                      now: instant, calendar: calendar("Europe/London"))
        let kyiv = summary(fluids: [fluid])
        #expect(london.hydration.value == 250)
        #expect(kyiv.hydration.value == 0)
    }

    @Test func dstDayHas23HoursAndStillCountsLateEntries() {
        let ny = calendar("America/New_York")
        let springDay = date(2026, 3, 8, 12, in: ny)
        #expect(ny.dateInterval(of: .day, for: springDay)!.duration == 23 * 3600)
        let late = FluidItem(amountML: 500, beverage: .water, calories: 0, timestamp: date(2026, 3, 8, 23, 30, in: ny))
        let s = DaySummary.build(day: springDay, fluids: [late], foods: [], medications: [], logs: [:],
                                 hydrationGoalML: 2500, calorieGoal: 2000, now: springDay, calendar: ny)
        #expect(s.hydration.value == 500)
    }

    @Test func activityIsNewestFirst() {
        let s = summary(
            fluids: [FluidItem(amountML: 250, beverage: .water, calories: 0, timestamp: date(2026, 9, 16, 9))],
            foods: [FoodItem(name: "Lunch", calories: 650, timestamp: date(2026, 9, 16, 12))]
        )
        #expect(s.activity.map(\.date) == [date(2026, 9, 16, 12), date(2026, 9, 16, 9)])
    }
}

@Suite struct MedicationScheduleTests {
    let cal = calendar()

    @Test func dailyOccurrencesSortedAndDeduplicated() {
        let m = med("Vitamin D", [(20, 0), (8, 0), (8, 0)])
        let occ = m.occurrences(on: date(2026, 9, 16), calendar: cal)
        #expect(occ.map(\.scheduledAt) == [date(2026, 9, 16, 8), date(2026, 9, 16, 20)])
        #expect(Set(occ.map(\.key)).count == 2)
    }

    @Test func weekdaysFilter() {
        // 2026-09-16 is a Wednesday (weekday 4).
        let m = med("X", [(8, 0)], weekdays: [2, 4])
        #expect(m.occurrences(on: date(2026, 9, 16), calendar: cal).count == 1)
        #expect(m.occurrences(on: date(2026, 9, 17), calendar: cal).isEmpty)
    }

    @Test func startAndEndDatesAreInclusiveDays() {
        let m = med("X", [(8, 0)], start: date(2026, 9, 16, 15), end: date(2026, 9, 18, 1))
        #expect(m.occurrences(on: date(2026, 9, 15), calendar: cal).isEmpty)
        #expect(m.occurrences(on: date(2026, 9, 16), calendar: cal).count == 1)
        #expect(m.occurrences(on: date(2026, 9, 18), calendar: cal).count == 1)
        #expect(m.occurrences(on: date(2026, 9, 19), calendar: cal).isEmpty)
    }

    @Test func inactiveMedicationHasNoDoses() {
        var m = med("X", [(8, 0)])
        m.isActive = false
        #expect(m.occurrences(on: date(2026, 9, 16), calendar: cal).isEmpty)
    }

    @Test func dstSpringForwardGapMovesToNextValidTime() {
        let ny = calendar("America/New_York")
        let occ = med("X", [(2, 30), (8, 0)]).occurrences(on: date(2026, 3, 8, in: ny), calendar: ny)
        #expect(occ.count == 2)
        #expect(ny.component(.hour, from: occ[0].scheduledAt) == 3)
        #expect(ny.isDate(occ[0].scheduledAt, inSameDayAs: date(2026, 3, 8, 12, in: ny)))
        // 08:00 is still 08:00 wall clock even though the day is 23 hours long.
        #expect(ny.component(.hour, from: occ[1].scheduledAt) == 8)
    }

    @Test func dstFallBackRepeatedTimeFiresOnce() {
        let ny = calendar("America/New_York")
        let occ = med("X", [(1, 30)]).occurrences(on: date(2026, 11, 1, in: ny), calendar: ny)
        #expect(occ.count == 1)
        // First 01:30 is EDT (UTC-4) → 05:30 UTC.
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        #expect(utc.component(.hour, from: occ[0].scheduledAt) == 5)
    }

    @Test func timeZoneChangeKeepsWallClockAndDoseKey() {
        let m = med("X", [(8, 0)])
        let kyiv = calendar("Europe/Kyiv"), ny = calendar("America/New_York")
        let a = m.occurrences(on: date(2026, 9, 16, 12, in: kyiv), calendar: kyiv)[0]
        let b = m.occurrences(on: date(2026, 9, 16, 12, in: ny), calendar: ny)[0]
        #expect(kyiv.component(.hour, from: a.scheduledAt) == 8)
        #expect(ny.component(.hour, from: b.scheduledAt) == 8)
        #expect(a.scheduledAt != b.scheduledAt)
        #expect(a.key == b.key)
    }

    @Test func statusResolution() {
        let t = date(2026, 9, 16, 8)
        #expect(DoseStatus.resolve(scheduledAt: t, log: nil, now: t.addingTimeInterval(-60)) == .upcoming)
        #expect(DoseStatus.resolve(scheduledAt: t, log: nil, now: t) == .due)
        #expect(DoseStatus.resolve(scheduledAt: t, log: nil, now: t.addingTimeInterval(59 * 60)) == .due)
        #expect(DoseStatus.resolve(scheduledAt: t, log: nil, now: t.addingTimeInterval(60 * 60)) == .missed)
        #expect(DoseStatus.resolve(scheduledAt: t, log: .taken, now: t.addingTimeInterval(-3600)) == .taken)
        #expect(DoseStatus.resolve(scheduledAt: t, log: .skipped, now: t) == .skipped)
        #expect(DoseStatus.resolve(scheduledAt: t, log: .missed, now: t) == .missed)
    }

    @Test func multipleMedicationsSummaryAndNextDose() {
        let vitD = med("Vitamin D", [(8, 0)])
        let x = med("Medication X", [(14, 0), (20, 0)])
        let now = date(2026, 9, 16, 12)
        let key = vitD.occurrences(on: now, calendar: cal)[0].key
        let s = DaySummary.build(day: now, fluids: [], foods: [], medications: [x, vitD],
                                 logs: [key: (.taken, date(2026, 9, 16, 8, 5))],
                                 hydrationGoalML: 1, calorieGoal: 1, now: now, calendar: cal)
        #expect(s.doses.map(\.occurrence.medicationName) == ["Vitamin D", "Medication X", "Medication X"])
        #expect(s.doses.map(\.status) == [.taken, .upcoming, .upcoming])
        #expect(s.dosesTaken == 1)
        #expect(s.medicationProgress.goal == 3)
        #expect(s.nextDose?.occurrence.scheduledAt == date(2026, 9, 16, 14))
        #expect(s.activity.count == 1)
    }

    @Test func missedDoseWhenNoLogPastGrace() {
        let now = date(2026, 9, 16, 21, 30)
        let s = DaySummary.build(day: now, fluids: [], foods: [], medications: [med("X", [(8, 0), (21, 0)])],
                                 logs: [:], hydrationGoalML: 1, calorieGoal: 1, now: now, calendar: cal)
        #expect(s.doses.map(\.status) == [.missed, .due])
        #expect(s.nextDose?.occurrence.time == TimeOfDay(hour: 21, minute: 0))
    }
}
