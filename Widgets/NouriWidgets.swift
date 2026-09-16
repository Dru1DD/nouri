import NouriKit
import SwiftUI
import WidgetKit

@main
struct NouriWidgetBundle: WidgetBundle {
    var body: some Widget {
        HydrationWidget()
        MedicationWidget()
    }
}

// MARK: - Timeline

struct DayEntry: TimelineEntry {
    let date: Date
    let summary: DaySummary

    static let placeholder = DayEntry(date: .now, summary: DaySummary.build(
        day: .now,
        fluids: [FluidItem(amountML: 1650, beverage: .water, calories: 0, timestamp: .now)],
        foods: [FoodItem(name: "Sample", calories: 1420, timestamp: .now)],
        medications: [], logs: [:], hydrationGoalML: 2500, calorieGoal: 2000,
        now: .now, calendar: .current
    ))
}

struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(context.isPreview ? .placeholder : load(at: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let now = Date.now
        let entry = load(at: now)
        // The app reloads timelines on every change; this only handles time passing
        // (a dose becoming due, midnight rollover).
        let cal = Calendar.current
        let midnight = cal.dateInterval(of: .day, for: now)?.end ?? now.addingTimeInterval(3600)
        let nextDose = entry.summary.doses.map(\.occurrence.scheduledAt).first { $0 > now }
        let refresh = [midnight, nextDose, now.addingTimeInterval(30 * 60)].compactMap { $0 }.min() ?? midnight
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func load(at now: Date) -> DayEntry {
        guard let container = try? NouriStore.makeContainer() else { return .placeholder }
        let summary = NouriStore(container: container).summary(for: now, now: now, calendar: .current)
        return DayEntry(date: now, summary: summary)
    }
}

// MARK: - Hydration

struct HydrationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Hydration", provider: DayProvider()) { entry in
            HydrationView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Hydration")
        .description("Today's water intake.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
        #else
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        #endif
    }
}

struct HydrationView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    private var progress: GoalProgress { entry.summary.hydration }
    private var liters: String { String(localized: "\(Format.liters(progress.value)) L") }

    var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Hydration")
            .accessibilityValue("\(liters) of \(Format.liters(progress.goal)) liters, \(progress.percent) percent")
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: progress.fraction) {
                Image(systemName: "drop.fill")
            } currentValueLabel: {
                Text("\(progress.percent)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryInline:
            Label("\(progress.percent)% · \(liters)", systemImage: "drop.fill")
        #if os(watchOS)
        case .accessoryCorner:
            Text("💧\(progress.percent)%")
                .widgetLabel { Gauge(value: progress.fraction) { Text("Water") } }
        #endif
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Label("Hydration", systemImage: "drop.fill").font(.headline)
                Text("\(liters) / \(Format.liters(progress.goal)) L")
                ProgressView(value: progress.fraction)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Label("Hydration", systemImage: "drop.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
                Text(liters).font(.title.bold().monospacedDigit())
                Text("of \(Format.liters(progress.goal)) L · \(progress.percent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: progress.fraction).tint(.blue)
            }
        }
    }
}

// MARK: - Medications

struct MedicationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Medications", provider: DayProvider()) { entry in
            MedicationStatusView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Medications")
        .description("Doses taken today and the next reminder.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        #else
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular, .accessoryInline])
        #endif
    }
}

struct MedicationStatusView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    private var summary: DaySummary { entry.summary }
    private var counts: String { "\(summary.dosesTaken)/\(summary.doses.count)" }
    private var next: String? {
        summary.nextDose.map { "\(Format.time($0.occurrence.scheduledAt)) \($0.occurrence.medicationName)" }
    }

    var body: some View {
        content
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Medications")
            .accessibilityValue(next.map { String(localized: "\(summary.dosesTaken) of \(summary.doses.count) taken, next \($0)") }
                                ?? String(localized: "\(summary.dosesTaken) of \(summary.doses.count) taken"))
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            Gauge(value: summary.medicationProgress.fraction) {
                Image(systemName: "pills.fill")
            } currentValueLabel: {
                Text(counts)
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryInline:
            Label(next.map { "\(counts) · \($0)" } ?? counts, systemImage: "pills.fill")
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Label("\(counts) taken", systemImage: "pills.fill").font(.headline)
                Text(next.map { String(localized: "Next: \($0)") } ?? String(localized: "All done for today"))
                    .lineLimit(2)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Label("Medications", systemImage: "pills.fill")
                    .font(.headline)
                    .foregroundStyle(.purple)
                Spacer()
                Text("\(counts) taken").font(.title2.bold().monospacedDigit())
                Text(next.map { String(localized: "Next: \($0)") }
                     ?? (summary.doses.isEmpty ? String(localized: "No doses today") : String(localized: "All done for today")))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
