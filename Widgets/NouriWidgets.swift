import AppIntents
import NouriKit
import SwiftUI
import WidgetKit

@main
struct NouriWidgetBundle: WidgetBundle {
    var body: some Widget {
        #if os(iOS)
        TodayWidget()
        #endif
        HydrationWidget()
        MedicationWidget()
    }
}

#if os(iOS)
struct NouriWidgetIntents: AppIntentsPackage {
    static var includedPackages: [any AppIntentsPackage.Type] { [NouriKitIntents.self] }
}
#endif

// MARK: - Timeline

struct DayEntry: TimelineEntry {
    let date: Date
    let summary: DaySummary
    let appearance: AppearancePreset

    static let placeholder = DayEntry(date: .now, summary: DaySummary.build(
        day: .now,
        fluids: [FluidItem(amountML: 1650, beverage: .water, calories: 0, timestamp: .now)],
        foods: [FoodItem(name: "Sample", calories: 1420, timestamp: .now)],
        medications: [
            MedicationInfo(name: "Vitamin D", dosage: 1, unit: "tablet",
                           schedule: MedicationSchedule(times: [TimeOfDay(hour: 8, minute: 0)]))
        ],
        logs: [:], hydrationGoalML: 2500, calorieGoal: 2000,
        now: .now, calendar: .current
    ), appearance: .default)
}

struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry { .placeholder }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) {
        completion(context.isPreview ? .placeholder : load(at: .now, family: context.family))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let now = Date.now
        let entry = load(at: now, family: context.family)
        let cal = Calendar.current
        let midnight = cal.dateInterval(of: .day, for: now)?.end ?? now.addingTimeInterval(3600)
        let nextDose = entry.summary.doses.map(\.occurrence.scheduledAt).first { $0 > now }
        let refresh = [midnight, nextDose, now.addingTimeInterval(30 * 60)].compactMap { $0 }.min() ?? midnight
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func load(at now: Date, family: WidgetFamily) -> DayEntry {
        AnalyticsStore().trackOncePerDay("widget_seen", ["family": "\(family)"])
        guard let container = try? NouriStore.makeContainer() else { return .placeholder }
        let store = NouriStore(container: container)
        let summary = store.summary(for: now, now: now, calendar: .current)
        return DayEntry(date: now, summary: summary, appearance: store.preferences().appearancePreset)
    }
}

// MARK: - Today

#if os(iOS)
/// Water and medications side by side (medium), plus today's doses (large).
/// Small and lock-screen sizes use the separate Hydration / Medications widgets.
struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Today", provider: DayProvider()) { entry in
            TodayView(entry: entry)
                .themedBackground(entry.appearance)
        }
        .configurationDisplayName("Today")
        .description("Water and medications together.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct TodayView: View {
    @Environment(\.widgetFamily) private var family
    let entry: DayEntry

    private var summary: DaySummary { entry.summary }
    private var water: GoalProgress { summary.hydration }
    private var next: DoseItem? { summary.nextDose }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                waterColumn
                medsColumn
            }
            if family == .systemLarge {
                Divider()
                doseList
                Spacer(minLength: 0)
            }
        }
    }

    private var waterColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Water", systemImage: "drop.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.appearance.waterEnd)
            Text("\(Format.liters(water.value)) L")
                .font(.title2.bold().monospacedDigit())
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("of \(Format.liters(water.goal)) L · \(water.percent)%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            ProgressView(value: water.fraction).tint(entry.appearance.waterEnd)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration")
        .accessibilityValue("\(Format.liters(water.value)) of \(Format.liters(water.goal)) liters, \(water.percent) percent")
    }

    private var medsColumn: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Medications", systemImage: "pills.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.appearance.medsEnd)
                .lineLimit(1)
            Text(summary.doses.isEmpty ? "—" : "\(summary.dosesTaken)/\(summary.doses.count)")
                .font(.title2.bold().monospacedDigit())
            Text(medsCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 0)
            ProgressView(value: summary.medicationProgress.fraction).tint(entry.appearance.medsEnd)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Medications")
        .accessibilityValue(medsCaption)
    }

    private var medsCaption: String {
        if let next {
            String(localized: "Next \(Format.time(next.occurrence.scheduledAt)) \(next.occurrence.medicationName)")
        } else if summary.doses.isEmpty {
            String(localized: "No doses today")
        } else {
            String(localized: "All done for today")
        }
    }

    @ViewBuilder
    private var doseList: some View {
        if summary.doses.isEmpty {
            Text("No doses today")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            ForEach(summary.doses.prefix(5)) { dose in
                HStack {
                    Text(Format.time(dose.occurrence.scheduledAt))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Text(dose.occurrence.medicationName)
                        .font(.caption)
                        .lineLimit(1)
                    Spacer()
                    Label(dose.status.label, systemImage: dose.status.symbol)
                        .font(.caption2)
                        .foregroundStyle(dose.status == .taken ? entry.appearance.medsEnd : .secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
#endif

private extension View {
    /// Palette background (or the system one) with a soft wash, and palette text color.
    func themedBackground(_ preset: AppearancePreset) -> some View {
        foregroundStyle(preset.text.map(AnyShapeStyle.init) ?? AnyShapeStyle(.primary))
            .containerBackground(for: .widget) {
                ZStack {
                    if let background = preset.background {
                        background
                    } else {
                        Rectangle().fill(.fill.tertiary)
                    }
                    preset.backgroundWash
                }
            }
    }
}

// MARK: - Hydration

struct HydrationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Hydration", provider: DayProvider()) { entry in
            HydrationView(entry: entry)
                .themedBackground(entry.appearance)
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
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Hydration")
            .accessibilityValue("\(liters) of \(Format.liters(progress.goal)) liters, \(progress.percent) percent")
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            SingleProgressRing(progress: progress, gradient: entry.appearance.waterGradient,
                               centerText: "\(progress.percent)", accessibilityName: "Hydration")
        case .accessoryInline:
            Text("\(progress.percent)% · \(liters)")
        #if os(watchOS)
        case .accessoryCorner:
            Image(systemName: "drop.fill")
                .font(.title3)
                .foregroundStyle(entry.appearance.waterEnd)
                .widgetLabel {
                    Gauge(value: progress.fraction) { Text("Water") }
                        .tint(entry.appearance.waterEnd)
                }
        #endif
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Hydration").font(.headline)
                Text("\(liters) / \(Format.liters(progress.goal)) L")
                    .minimumScaleFactor(0.7)
                ProgressView(value: progress.fraction).tint(entry.appearance.waterEnd)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text("Hydration")
                    .font(.headline)
                    .foregroundStyle(entry.appearance.waterEnd)
                Spacer()
                Text(liters)
                    .font(.title.bold().monospacedDigit())
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("of \(Format.liters(progress.goal)) L · \(progress.percent)%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                ProgressView(value: progress.fraction).tint(entry.appearance.waterEnd)
            }
        }
    }
}

// MARK: - Medications

struct MedicationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Medications", provider: DayProvider()) { entry in
            MedicationStatusView(entry: entry)
                .themedBackground(entry.appearance)
                .widgetURL(URL(string: "nouri://medications"))
        }
        .configurationDisplayName("Medications")
        .description("Doses taken today and the next reminder.")
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryRectangular, .accessoryInline])
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
            SingleProgressRing(progress: summary.medicationProgress, gradient: entry.appearance.medsGradient,
                               centerText: counts, accessibilityName: "Medications")
        case .accessoryInline:
            Text(next.map { "\(counts) · \($0)" } ?? counts)
        #if os(watchOS)
        case .accessoryCorner:
            Image(systemName: "pills.fill")
                .font(.title3)
                .foregroundStyle(entry.appearance.medsEnd)
                .widgetLabel {
                    Gauge(value: summary.medicationProgress.fraction) { Text(counts) }
                        .tint(entry.appearance.medsEnd)
                }
        #endif
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("\(counts) taken").font(.headline)
                Text(next.map { String(localized: "Next: \($0)") } ?? String(localized: "All done for today"))
                    .lineLimit(2)
            }
        default:
            VStack(alignment: .leading, spacing: 6) {
                Text("Medications")
                    .font(.headline)
                    .foregroundStyle(entry.appearance.medsEnd)
                Spacer()
                Text("\(counts) taken").font(.title2.bold().monospacedDigit()).minimumScaleFactor(0.7)
                Text(next.map { String(localized: "Next: \($0)") }
                     ?? (summary.doses.isEmpty ? String(localized: "No doses today") : String(localized: "All done for today")))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}
