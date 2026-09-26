import Charts
import NouriKit
import SwiftUI

struct ActivityDashboardView: View {
    @Environment(AppModel.self) private var model

    private var stats: HydrationStats { model.hydrationStats(days: 7) }

    var body: some View {
        List {
            todaySection
            weekSection
            beveragesSection
        }
        .navigationTitle("Dashboard")
        .accessibilityIdentifier("activity-dashboard")
    }

    private var todaySection: some View {
        Section("Today") {
            if stats.todayDrinkCount == 0 && stats.todayAmountML == 0 {
                ContentUnavailableView {
                    Label("No drinks yet", systemImage: "drop")
                } description: {
                    Text("Start logging drinks to see your hydration trends.")
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Format.liters(stats.todayAmountML)) / \(Format.liters(stats.todayGoalML)) L")
                        .font(.title2.weight(.semibold).monospacedDigit())
                    Text("\(stats.todayPercent)%")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                    LabeledContent("Drinks", value: "\(stats.todayDrinkCount)")
                    LabeledContent("Remaining", value: String(localized: "\(Format.ml(stats.remainingML)) ml"))
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Today \(Format.liters(stats.todayAmountML)) of \(Format.liters(stats.todayGoalML)) liters, \(stats.todayPercent) percent, \(stats.todayDrinkCount) drinks, \(Format.ml(stats.remainingML)) milliliters remaining")
            }
        }
    }

    private var weekSection: some View {
        Section("This Week") {
            if stats.totalDrinks == 0 {
                Text("No activity this week yet.")
                    .foregroundStyle(.secondary)
            } else {
                LabeledContent("Average", value: String(localized: "\(Format.liters(stats.averageDailyML)) L / day"))
                if let top = stats.mostCommonBeverage {
                    LabeledContent("Most common", value: top.title)
                }
                Chart(stats.days) { point in
                    BarMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("ml", point.amountML)
                    )
                    .foregroundStyle(point.goalMet ? Color.green : Color.blue)
                }
                .frame(height: 160)
                .accessibilityLabel("Seven day hydration chart")
                ForEach(stats.days) { point in
                    HStack {
                        Text(point.day.formatted(.dateTime.weekday(.abbreviated)))
                        Spacer()
                        Text("\(Format.liters(point.amountML)) L · \(point.drinkCount)")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Image(systemName: point.goalMet ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(point.goalMet ? .green : .secondary)
                            .accessibilityLabel(point.goalMet ? "Goal met" : "Goal not met")
                    }
                    .font(.subheadline)
                }
            }
        }
    }

    private var beveragesSection: some View {
        Section("Beverages") {
            if stats.beverageCounts.isEmpty {
                Text("Log drinks to see which beverages you have most often.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(stats.beverageCounts) { item in
                    LabeledContent {
                        Text("\(item.drinkCount) · \(Format.ml(item.amountML)) ml")
                            .monospacedDigit()
                    } label: {
                        Label(item.beverage.title, systemImage: item.beverage.symbol)
                    }
                }
            }
        }
    }
}
