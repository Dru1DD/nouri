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
        completion(context.isPreview ? .placeholder : load(at: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let now = Date.now
        let entry = load(at: now)
        let cal = Calendar.current
        let midnight = cal.dateInterval(of: .day, for: now)?.end ?? now.addingTimeInterval(3600)
        let nextDose = entry.summary.doses.map(\.occurrence.scheduledAt).first { $0 > now }
        let refresh = [midnight, nextDose, now.addingTimeInterval(30 * 60)].compactMap { $0 }.min() ?? midnight
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }

    private func load(at now: Date) -> DayEntry {
        guard let container = try? NouriStore.makeContainer() else { return .placeholder }
        let store = NouriStore(container: container)
        let summary = store.summary(for: now, now: now, calendar: .current)
        return DayEntry(date: now, summary: summary, appearance: store.preferences().appearancePreset)
    }
}

// MARK: - Today

#if os(iOS)
/// Concentric water + medication rings with today's numbers (medium), plus today's doses (large).
/// Small and lock-screen sizes use the separate Hydration / Medications widgets.
struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Today", provider: DayProvider()) { entry in
            TodayView(entry: entry)
                .vividBackground(.today, entry.appearance)
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
            HStack(spacing: 16) {
                ZStack {
                    DualProgressRings(water: water, medications: summary.medicationProgress, preset: entry.appearance,
                                      showMedications: !summary.doses.isEmpty, centerText: "", lineWidth: 13)
                    Image(systemName: "drop.fill")
                        .font(.title3)
                        .foregroundStyle(entry.appearance.waterGradient)
                        .accessibilityHidden(true)
                }
                .padding(6)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: 124)
                VStack(alignment: .leading, spacing: 8) {
                    waterStat
                    medsStat
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            if family == .systemLarge {
                Divider().overlay(.white.opacity(0.3))
                doseList
                Spacer(minLength: 0)
            }
        }
    }

    private var waterStat: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label("Water", systemImage: "drop.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.appearance.waterStart)
            Text("\(Format.liters(water.value)) L")
                .font(.title3.bold().monospacedDigit())
                .contentTransition(.numericText(value: water.value))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text("of \(Format.liters(water.goal)) L · \(water.percent)%")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hydration")
        .accessibilityValue("\(Format.liters(water.value)) of \(Format.liters(water.goal)) liters, \(water.percent) percent")
    }

    private var medsStat: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label("Medications", systemImage: "pills.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(entry.appearance.medsStart)
                .lineLimit(1)
            Text(summary.doses.isEmpty ? "—" : "\(summary.dosesTaken)/\(summary.doses.count)")
                .font(.title3.bold().monospacedDigit())
                .contentTransition(.numericText(value: Double(summary.dosesTaken)))
            Text(medsCaption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
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
                        .foregroundStyle(dose.status == .taken ? entry.appearance.medsStart : .secondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}
#endif

// MARK: - Style

private enum WidgetStyle { case water, medications, today }

private extension View {
    /// Saturated gradient in the palette's hue with a soft glow, light text on top.
    /// Tinted and clear Home Screens drop the background and recolor the content on their own.
    func vividBackground(_ style: WidgetStyle, _ preset: AppearancePreset) -> some View {
        let colors: [Color]
        let glows: [(Color, UnitPoint)]
        switch style {
        case .water:
            colors = [preset.waterEnd.mix(with: .black, by: 0.25), preset.waterEnd.mix(with: .black, by: 0.45)]
            glows = [(preset.waterStart, .topLeading)]
        case .medications:
            colors = [preset.medsEnd.mix(with: .black, by: 0.4), preset.medsEnd.mix(with: .black, by: 0.5)]
            glows = [(preset.medsStart, .topLeading)]
        case .today:
            colors = [preset.waterEnd.mix(with: .black, by: 0.7), preset.waterEnd.mix(with: .black, by: 0.88)]
            glows = [(preset.waterStart, .topLeading), (preset.medsStart, .bottomTrailing)]
        }
        return environment(\.colorScheme, .dark)
            .foregroundStyle(.white)
            .containerBackground(for: .widget) {
                ZStack {
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    ForEach(glows.indices, id: \.self) { i in
                        RadialGradient(colors: [glows[i].0.opacity(0.25), .clear], center: glows[i].1,
                                       startRadius: 0, endRadius: 170)
                    }
                }
            }
    }
}

/// Big ring with a symbol and value inside, for the small Home Screen widgets.
private struct BadgeRing: View {
    let progress: GoalProgress
    let symbol: String
    let value: String
    let animatedValue: Double
    let accessibilityName: String

    var body: some View {
        ZStack {
            SingleProgressRing(progress: progress,
                               gradient: LinearGradient(colors: [.white, .white.opacity(0.75)], startPoint: .top, endPoint: .bottom),
                               centerText: "", accessibilityName: accessibilityName, lineWidth: 11)
            VStack(spacing: 0) {
                Image(systemName: symbol).font(.title3)
                Text(verbatim: value)
                    .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                    .contentTransition(.numericText(value: animatedValue))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
        }
        .padding(6)
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Hydration

struct HydrationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Hydration", provider: DayProvider()) { entry in
            HydrationView(entry: entry)
                .vividBackground(.water, entry.appearance)
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
                    Gauge(value: progress.fraction) {
                        Text("Water")
                    } currentValueLabel: {
                        EmptyView()
                    } minimumValueLabel: {
                        Text(verbatim: "")
                    } maximumValueLabel: {
                        Text(verbatim: "\(progress.percent)%")
                    }
                    .tint(entry.appearance.waterEnd)
                }
        #endif
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Hydration").font(.headline)
                Text("\(liters) / \(Format.liters(progress.goal)) L")
                    .minimumScaleFactor(0.7)
                ProgressView(value: progress.fraction).tint(entry.appearance.waterStart)
            }
        default:
            VStack(spacing: 4) {
                BadgeRing(progress: progress, symbol: "drop.fill", value: "\(progress.percent)%",
                          animatedValue: Double(progress.percent), accessibilityName: "Hydration")
                Text(liters)
                    .font(.headline.monospacedDigit())
                    .contentTransition(.numericText(value: progress.value))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("of \(Format.liters(progress.goal)) L")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - Medications

struct MedicationWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Medications", provider: DayProvider()) { entry in
            MedicationStatusView(entry: entry)
                .vividBackground(.medications, entry.appearance)
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
                    Gauge(value: summary.medicationProgress.fraction) {
                        Text(counts)
                    } currentValueLabel: {
                        EmptyView()
                    } minimumValueLabel: {
                        Text(verbatim: "")
                    } maximumValueLabel: {
                        Text(verbatim: "\(summary.medicationProgress.percent)%")
                    }
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
            VStack(spacing: 4) {
                BadgeRing(progress: summary.medicationProgress, symbol: "pills.fill",
                          value: summary.doses.isEmpty ? "—" : counts,
                          animatedValue: Double(summary.dosesTaken), accessibilityName: "Medications")
                Text(next.map { String(localized: "Next: \($0)") }
                     ?? (summary.doses.isEmpty ? String(localized: "No doses today") : String(localized: "All done for today")))
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
        }
    }
}
