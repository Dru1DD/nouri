import Foundation

public struct GoalProgress: Hashable, Sendable {
    public var value: Double
    public var goal: Double

    public init(value: Double, goal: Double) {
        self.value = value
        self.goal = goal
    }

    /// 0...1, clamped. A non-positive goal counts as no progress.
    public var fraction: Double { goal > 0 ? min(max(value / goal, 0), 1) : 0 }
    /// Unclamped whole percent, so "130%" can be shown when the goal is exceeded.
    public var percent: Int { goal > 0 ? Int((value / goal * 100).rounded(.down)) : 0 }
}

public struct FluidItem: Hashable, Identifiable, Sendable {
    public var id: UUID
    public var amountML: Double
    public var beverage: BeverageType
    public var calories: Double
    public var timestamp: Date

    public init(id: UUID = UUID(), amountML: Double, beverage: BeverageType, calories: Double, timestamp: Date) {
        self.id = id
        self.amountML = amountML
        self.beverage = beverage
        self.calories = calories
        self.timestamp = timestamp
    }

    /// Distinct drinks (by type and amount) other than water, newest first: one-tap repeats.
    /// Each keeps the calories it was last logged with, so a customised latte stays customised.
    public static func recent(_ fluids: [FluidItem], limit: Int = 3) -> [FluidItem] {
        var seen = Set<String>()
        return fluids.sorted { $0.timestamp > $1.timestamp }
            .filter { $0.beverage != .water && seen.insert("\($0.beverage.rawValue)|\($0.amountML)").inserted }
            .prefix(limit)
            .map { $0 }
    }
}

public struct FoodItem: Hashable, Identifiable, Sendable {
    public var id: UUID
    public var name: String
    public var calories: Double
    public var timestamp: Date

    public init(id: UUID = UUID(), name: String, calories: Double, timestamp: Date) {
        self.id = id
        self.name = name
        self.calories = calories
        self.timestamp = timestamp
    }
}

public struct DoseItem: Hashable, Identifiable, Sendable {
    public var occurrence: DoseOccurrence
    public var status: DoseStatus
    public var loggedAt: Date?

    public var id: String { occurrence.key }
}

public enum ActivityItem: Hashable, Identifiable, Sendable {
    case fluid(FluidItem)
    case food(FoodItem)
    case dose(DoseItem)

    public var id: String {
        switch self {
        case .fluid(let f): "fluid-\(f.id)"
        case .food(let f): "food-\(f.id)"
        case .dose(let d): "dose-\(d.id)"
        }
    }

    public var date: Date {
        switch self {
        case .fluid(let f): f.timestamp
        case .food(let f): f.timestamp
        case .dose(let d): d.loggedAt ?? d.occurrence.scheduledAt
        }
    }
}

/// Everything the dashboards show for one calendar day. Pure value, built from plain inputs.
public struct DaySummary: Hashable, Sendable {
    public var day: Date
    public var hydration: GoalProgress
    public var calories: GoalProgress
    public var beverageCalories: Double
    public var doses: [DoseItem]
    public var fluids: [FluidItem]
    public var foods: [FoodItem]

    /// Alcohol logged this day; shown separately since it doesn't count toward hydration.
    public var alcoholML: Double {
        fluids.filter { !$0.beverage.countsTowardHydration }.reduce(0) { $0 + $1.amountML }
    }

    public var dosesTaken: Int { doses.filter { $0.status == .taken }.count }
    public var medicationProgress: GoalProgress { GoalProgress(value: Double(dosesTaken), goal: Double(doses.count)) }
    public var nextDose: DoseItem? { doses.first { $0.status == .upcoming || $0.status == .due } }

    /// Newest first. Doses appear once they have been acted on.
    public var activity: [ActivityItem] {
        let items = fluids.map(ActivityItem.fluid) + foods.map(ActivityItem.food)
            + doses.filter { $0.loggedAt != nil }.map(ActivityItem.dose)
        return items.sorted { $0.date > $1.date }
    }

    public static func build(
        day: Date,
        fluids: [FluidItem],
        foods: [FoodItem],
        medications: [MedicationInfo],
        logs: [String: (status: DoseLogStatus, at: Date?)],
        hydrationGoalML: Double,
        calorieGoal: Double,
        now: Date,
        calendar: Calendar
    ) -> DaySummary {
        guard let interval = calendar.dateInterval(of: .day, for: day) else {
            preconditionFailure("Calendar cannot produce a day interval")
        }
        let dayFluids = fluids.filter { interval.contains($0.timestamp) && $0.timestamp < interval.end }
        let dayFoods = foods.filter { interval.contains($0.timestamp) && $0.timestamp < interval.end }
        let totalML = dayFluids.filter(\.beverage.countsTowardHydration).reduce(0) { $0 + $1.amountML }
        let beverageKcal = dayFluids.reduce(0) { $0 + $1.calories }
        let foodKcal = dayFoods.reduce(0) { $0 + $1.calories }

        let doses = medications
            .flatMap { $0.occurrences(on: interval.start, calendar: calendar) }
            .sorted { ($0.scheduledAt, $0.medicationName) < ($1.scheduledAt, $1.medicationName) }
            .map { occ in
                let log = logs[occ.key]
                return DoseItem(occurrence: occ,
                                status: DoseStatus.resolve(scheduledAt: occ.scheduledAt, log: log?.status, now: now),
                                loggedAt: log?.at)
            }

        return DaySummary(
            day: interval.start,
            hydration: GoalProgress(value: totalML, goal: hydrationGoalML),
            calories: GoalProgress(value: foodKcal + beverageKcal, goal: calorieGoal),
            beverageCalories: beverageKcal,
            doses: doses,
            fluids: dayFluids,
            foods: dayFoods
        )
    }
}

// MARK: - Hydration dashboard stats

public struct BeverageCount: Hashable, Identifiable, Sendable {
    public var beverage: BeverageType
    public var drinkCount: Int
    public var amountML: Double
    public var id: String { beverage.rawValue }
}

public struct DayHydrationPoint: Hashable, Identifiable, Sendable {
    public var day: Date
    public var amountML: Double
    public var goalML: Double
    public var drinkCount: Int
    public var goalMet: Bool { goalML > 0 && amountML >= goalML }
    public var id: Date { day }
}

public struct HydrationStats: Hashable, Sendable {
    public var todayAmountML: Double
    public var todayGoalML: Double
    public var todayPercent: Int
    public var todayDrinkCount: Int
    public var remainingML: Double
    public var averageDailyML: Double
    public var totalDrinks: Int
    public var beverageCounts: [BeverageCount]
    public var days: [DayHydrationPoint]
    public var mostCommonBeverage: BeverageType?

    public static func build(days: [DaySummary], calendar: Calendar = .current) -> HydrationStats {
        let ordered = days.sorted { $0.day < $1.day }
        let today = ordered.last
        let points = ordered.map {
            DayHydrationPoint(day: $0.day, amountML: $0.hydration.value, goalML: $0.hydration.goal,
                              drinkCount: $0.fluids.filter(\.beverage.countsTowardHydration).count)
        }
        var counts: [BeverageType: (n: Int, ml: Double)] = [:]
        for day in ordered {
            for f in day.fluids where f.beverage.countsTowardHydration {
                let cur = counts[f.beverage] ?? (0, 0)
                counts[f.beverage] = (cur.n + 1, cur.ml + f.amountML)
            }
        }
        let beverageCounts = counts
            .map { BeverageCount(beverage: $0.key, drinkCount: $0.value.n, amountML: $0.value.ml) }
            .sorted { ($0.drinkCount, $0.amountML) > ($1.drinkCount, $1.amountML) }
        let avg = points.isEmpty ? 0 : points.map(\.amountML).reduce(0, +) / Double(points.count)
        let amount = today?.hydration.value ?? 0
        let goal = today?.hydration.goal ?? 2500
        return HydrationStats(
            todayAmountML: amount,
            todayGoalML: goal,
            todayPercent: GoalProgress(value: amount, goal: goal).percent,
            todayDrinkCount: today.map { $0.fluids.filter(\.beverage.countsTowardHydration).count } ?? 0,
            remainingML: max(0, goal - amount),
            averageDailyML: avg,
            totalDrinks: points.map(\.drinkCount).reduce(0, +),
            beverageCounts: beverageCounts,
            days: points,
            mostCommonBeverage: beverageCounts.first?.beverage
        )
    }
}
