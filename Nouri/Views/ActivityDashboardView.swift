import Charts
import NouriKit
import SwiftUI

struct ActivityDashboardView: View {
    @Environment(AppModel.self) private var model

    private var week: [DaySummary] { model.history(days: 7).reversed() }
    private var stats: HydrationStats { HydrationStats.build(days: week) }
    private var dosesScheduled: Int { week.map(\.doses.count).reduce(0, +) }
    private var dosesTaken: Int { week.map(\.dosesTaken).reduce(0, +) }
    private var today: DaySummary { model.today }

    var body: some View {
        List {
            todaySection
            weekWaterSection
            weekMedsSection
            beveragesSection
        }
        .themedBackground(model.appearancePreset)
        .navigationTitle("Dashboard")
        .accessibilityIdentifier("activity-dashboard")
    }

    private var todaySection: some View {
        Section("Today") {
            if stats.todayDrinkCount == 0 && today.doses.isEmpty {
                ContentUnavailableView {
                    Label("Nothing logged yet", systemImage: "chart.bar")
                } description: {
                    Text("Log a drink or mark a dose to see today here.")
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    metricBlock(
                        title: "Water",
                        value: String(localized: "\(Format.liters(today.hydration.value)) / \(Format.liters(today.hydration.goal)) L"),
                        percent: today.hydration.percent,
                        progress: today.hydration.fraction,
                        tint: model.appearancePreset.waterEnd,
                        extra: String(localized: "\(stats.todayDrinkCount) drinks · \(Format.ml(stats.remainingML)) ml left")
                    )
                    metricBlock(
                        title: "Medications",
                        value: today.doses.isEmpty
                            ? String(localized: "No doses today")
                            : String(localized: "\(today.dosesTaken) / \(today.doses.count) taken"),
                        percent: today.doses.isEmpty ? nil : today.medicationProgress.percent,
                        progress: today.doses.isEmpty ? 0 : today.medicationProgress.fraction,
                        tint: model.appearancePreset.medsEnd,
                        extra: today.nextDose.map {
                            String(localized: "Next \(Format.time($0.occurrence.scheduledAt)) \($0.occurrence.medicationName)")
                        }
                    )
                }
                .accessibilityElement(children: .combine)
            }
        }
    }

    private func metricBlock(title: String, value: String, percent: Int?, progress: Double, tint: Color, extra: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.headline).foregroundStyle(tint)
                Spacer()
                if let percent {
                    Text("\(percent)%").font(.subheadline.monospacedDigit()).foregroundStyle(.secondary)
                }
            }
            Text(value).font(.title3.weight(.semibold).monospacedDigit())
            ProgressView(value: progress).tint(tint)
            if let extra {
                Text(extra).font(.caption).foregroundStyle(.secondary)
            }
        }
    }

    private var weekWaterSection: some View {
        Section("Water this week") {
            if stats.totalDrinks == 0 {
                Text("No drinks this week yet.")
                    .foregroundStyle(.secondary)
            } else {
                LabeledContent("Average", value: String(localized: "\(Format.liters(stats.averageDailyML)) L / day"))
                Chart(stats.days) { point in
                    BarMark(
                        x: .value("Day", point.day, unit: .day),
                        y: .value("ml", point.amountML)
                    )
                    .foregroundStyle(model.appearancePreset.waterEnd.opacity(point.goalMet ? 1 : 0.45))
                }
                .frame(height: 140)
                .accessibilityLabel("Seven day hydration chart")
            }
        }
    }

    private var weekMedsSection: some View {
        Section("Medications this week") {
            if dosesScheduled == 0 {
                Text("No doses scheduled this week.")
                    .foregroundStyle(.secondary)
            } else {
                LabeledContent("Taken") {
                    Text("\(dosesTaken) / \(dosesScheduled)")
                        .monospacedDigit()
                }
                Chart(week, id: \.day) { day in
                    BarMark(
                        x: .value("Day", day.day, unit: .day),
                        y: .value("Taken", day.dosesTaken)
                    )
                    .foregroundStyle(model.appearancePreset.medsEnd)
                }
                .frame(height: 140)
                .accessibilityLabel("Seven day medications chart")
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
