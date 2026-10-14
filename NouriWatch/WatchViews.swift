import NouriKit
import SwiftUI
import WatchKit

/// One metric per page, swiped horizontally. Each page opens on a full-screen ring;
/// scrolling down (Digital Crown or swipe) reveals its "+" buttons.
struct WatchRootView: View {
    @Environment(AppModel.self) private var model
    @SceneStorage("watch.page") private var page = Page.water

    enum Page: String {
        case water, calories, medications
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                WaterPage().tag(Page.water)
                if model.caloriesEnabled {
                    CaloriesPage().tag(Page.calories)
                }
                if !model.medications.isEmpty {
                    MedicationsPage().tag(Page.medications)
                }
            }
            .tabViewStyle(.page)
        }
    }
}

// MARK: - Pages

private struct WaterPage: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let progress = model.today.hydration
        let preset = model.appearancePreset
        // Only a dose that is due now: a one-tap ✓ must never resolve a future dose.
        let due = model.today.doses.first { $0.status == .due }
        MetricPage(tint: preset.waterEnd) {
            ZStack {
                ZStack {
                    DualProgressRings(water: progress, medications: progress, preset: preset,
                                      showMedications: false, centerText: "", lineWidth: 12)
                    VStack(spacing: -2) {
                        Text(Format.liters(progress.value))
                            .font(.system(.title2, design: .rounded, weight: .bold).monospacedDigit())
                            .contentTransition(.numericText())
                        Text("of \(Format.liters(progress.goal)) L")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: 130, maxHeight: 130)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Water")
                .accessibilityValue(String(localized: "\(Format.liters(progress.value)) of \(Format.liters(progress.goal)) liters, \(progress.percent) percent"))

                VStack {
                    HStack {
                        NavigationLink {
                            DrinkView()
                        } label: {
                            Image(systemName: "cup.and.saucer.fill")
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .background(.ultraThinMaterial, in: Circle())
                        .accessibilityLabel("Choose drink")
                        Spacer()
                        CornerButton(title: "+250", label: "Add 250 milliliters of water") {
                            model.addFluid(250)
                        }
                    }
                    Spacer()
                    HStack {
                        CornerButton(title: "+100", label: "Add 100 milliliters of water") {
                            model.addFluid(100)
                        }
                        Spacer()
                        if let due {
                            CornerButton(title: "✓", label: "Mark \(due.occurrence.medicationName) taken") {
                                Task { await model.setDose(due.occurrence, status: .taken) }
                            }
                        } else {
                            CornerButton(title: "+500", label: "Add 500 milliliters of water") {
                                model.addFluid(500)
                            }
                        }
                    }
                }
                .frame(maxWidth: 168, maxHeight: 168)
            }
        } actions: {
            UndoRow(matches: { if case .fluid = $0 { true } else { false } })
            CrownAmountLink(unit: String(localized: "ml"), tint: preset.waterEnd,
                            start: 250, range: 10...2000, step: 10) {
                model.addFluid($0)
            }
            ForEach(model.recentDrinks) { drink in
                AddButton(title: drink.beverage.title, unit: String(localized: "\(Format.ml(drink.amountML)) ml"),
                          tint: preset.waterEnd,
                          a11yLabel: String(localized: "Add \(drink.beverage.title), \(Format.ml(drink.amountML)) milliliters")) {
                    model.addFluid(drink.amountML, beverage: drink.beverage, calories: drink.calories)
                }
            }
        }
    }
}

private struct CornerButton: View {
    let title: String
    let label: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button {
            action()
            WKInterfaceDevice.current().play(.success)
        } label: {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.6)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial, in: Circle())
        .accessibilityLabel(label)
    }
}

private struct CaloriesPage: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let progress = model.today.calories
        MetricPage(tint: .orange) {
            BigRing(progress: progress, tint: .orange, symbol: "fork.knife",
                    value: Format.kcal(progress.value), unit: String(localized: "kcal"),
                    caption: String(localized: "of \(Format.kcal(progress.goal)) kcal · \(progress.percent)%"),
                    a11yName: "Calories")
        } actions: {
            UndoRow(matches: { if case .food = $0 { true } else { false } })
            ForEach([100.0, 250, 500], id: \.self) { kcal in
                AddButton(title: "+\(Int(kcal))", unit: String(localized: "kcal"), tint: .orange,
                          a11yLabel: String(localized: "Add \(Int(kcal)) kilocalories")) {
                    model.addCalories(kcal)
                }
            }
            CrownAmountLink(unit: String(localized: "kcal"), tint: .orange, start: 200, range: 10...2000, step: 10) {
                model.addCalories($0)
            }
            ForEach(model.presets) { preset in
                AddButton(title: preset.name, unit: Format.kcal(preset.calories), tint: .orange,
                          a11yLabel: String(localized: "Add \(preset.name), \(Format.kcal(preset.calories)) kilocalories")) {
                    model.addCalories(preset.calories, name: preset.name)
                }
            }
        }
    }
}

private struct MedicationsPage: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let today = model.today
        MetricPage(tint: model.appearancePreset.medsEnd) {
            BigRing(progress: today.medicationProgress, tint: model.appearancePreset.medsEnd, symbol: "pills.fill",
                    value: "\(today.dosesTaken)/\(today.doses.count)", unit: "",
                    caption: caption(today), a11yName: "Medications")
        } actions: {
            ForEach(today.doses) { DoseCard(dose: $0) }
        }
    }

    private func caption(_ today: DaySummary) -> String {
        if let next = today.nextDose {
            return String(localized: "Next: \(Format.time(next.occurrence.scheduledAt)) \(next.occurrence.medicationName)")
        }
        return today.doses.isEmpty ? String(localized: "No doses today") : String(localized: "All done for today")
    }
}

// MARK: - Building blocks

/// A page whose first screen is the hero ring; actions sit below the fold.
private struct MetricPage<Hero: View, Actions: View>: View {
    let tint: Color
    @ViewBuilder let hero: Hero
    @ViewBuilder let actions: Actions

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                hero
                    .containerRelativeFrame(.vertical, alignment: .center)
                    .padding(.bottom, 16)  // keeps the first button clear of the page dots

                actions
            }
        }
        .containerBackground(tint.opacity(0.4).gradient, for: .tabView)
    }
}

private struct BigRing: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let progress: GoalProgress
    let tint: Color
    let symbol: String
    let value: String
    let unit: String
    let caption: String
    let a11yName: LocalizedStringKey

    private let lineWidth: CGFloat = 14

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle().stroke(tint.opacity(0.25), lineWidth: lineWidth)
                Circle()
                    .trim(from: 0, to: progress.fraction)
                    .stroke(tint.gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : .spring(duration: 0.6), value: progress.fraction)
                VStack(spacing: -2) {
                    Image(systemName: symbol)
                        .font(.body)
                        .foregroundStyle(tint)
                    Text(value)
                        .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .contentTransition(.numericText())
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(lineWidth + 4)
            }
            .frame(maxWidth: 130, maxHeight: 130)

            Text(caption)
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(a11yName))
        .accessibilityValue(caption.isEmpty ? value : "\(value) \(unit), \(caption)")
    }
}

/// Full-width tinted "+N unit" button.
private struct AddButton: View {
    let title: String
    let unit: String
    let tint: Color
    let a11yLabel: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
            WKInterfaceDevice.current().play(.success)
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(.title3, design: .rounded, weight: .semibold).monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Spacer()
                Text(unit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .buttonStyle(.bordered)
        .tint(tint)
        .accessibilityLabel(a11yLabel)
    }
}

/// Opens the drink screen: pick what you drink (water by default), turn the crown for the amount, tap Add.
private struct DrinkView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var beverage = BeverageType.water
    @State private var amount = BeverageType.water.defaultServingML

    var body: some View {
        let kcal = beverage.defaultCalories(amountML: amount)
        VStack(spacing: 4) {
            Picker("Drink", selection: $beverage) {
                ForEach(BeverageType.allCases) { type in
                    Label(type.title, systemImage: type.symbol).tag(type)
                }
            }
            .pickerStyle(.navigationLink)
            .tint(model.appearancePreset.waterEnd)
            Spacer(minLength: 0)
            VStack(spacing: 0) {
                Text("\(Int(amount).formatted()) ml")
                    .font(.system(size: 40, weight: .semibold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                Text(model.caloriesEnabled && kcal > 0 ? String(localized: "≈ \(Format.kcal(kcal)) kcal") : " ")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Amount")
            .accessibilityValue("\(Int(amount).formatted()) ml")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: amount = min(amount + 10, 2000)
                case .decrement: amount = max(amount - 10, 10)
                @unknown default: break
                }
            }
            Spacer(minLength: 0)
            Button("Add") {
                model.addFluid(amount, beverage: beverage)
                WKInterfaceDevice.current().play(.success)
                dismiss()
            }
            .tint(model.appearancePreset.waterEnd)
        }
        .focusable()
        .digitalCrownRotation($amount, from: 10, through: 2000, by: 10,
                              sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
        .onChange(of: beverage) { amount = beverage.defaultServingML }
    }
}

/// Opens a screen where the Digital Crown picks any amount, for sizes the "+" buttons don't cover.
private struct CrownAmountLink: View {
    let unit: String
    let tint: Color
    let start: Double
    let range: ClosedRange<Double>
    let step: Double
    let add: (Double) -> Void

    var body: some View {
        NavigationLink {
            CrownAmountView(unit: unit, tint: tint, amount: start, range: range, step: step, add: add)
        } label: {
            Label("Custom amount", systemImage: "digitalcrown.arrow.clockwise")
        }
        .buttonStyle(.bordered)
        .tint(tint)
    }
}

private struct CrownAmountView: View {
    @Environment(\.dismiss) private var dismiss
    let unit: String
    let tint: Color
    @State var amount: Double
    let range: ClosedRange<Double>
    let step: Double
    let add: (Double) -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text(Int(amount).formatted())
                    .font(.system(size: 48, weight: .semibold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
                Text(unit).foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Custom amount")
            .accessibilityValue("\(Int(amount).formatted()) \(unit)")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: amount = min(amount + step, range.upperBound)
                case .decrement: amount = max(amount - step, range.lowerBound)
                @unknown default: break
                }
            }
            Spacer()
            Button("Add") {
                add(amount)
                WKInterfaceDevice.current().play(.success)
                dismiss()
            }
            .tint(tint)
        }
        .focusable()
        .digitalCrownRotation($amount, from: range.lowerBound, through: range.upperBound, by: step,
                              sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
    }
}

/// "Undo +250 ml", shown for a few seconds after a matching quick add.
private struct UndoRow: View {
    @Environment(AppModel.self) private var model
    let matches: (AppModel.LastAdded.Kind) -> Bool

    var body: some View {
        if let added = model.lastAdded, matches(added.kind) {
            Button {
                model.undoLastAdd()
                WKInterfaceDevice.current().play(.click)
            } label: {
                Label(text(added), systemImage: "arrow.uturn.backward")
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .task(id: added.id) {
                try? await Task.sleep(for: .seconds(5))
                model.dismissUndo(id: added.id)
            }
        }
    }

    private func text(_ added: AppModel.LastAdded) -> String {
        switch added.kind {
        case .fluid(let ml, _): String(localized: "Undo +\(Format.ml(ml)) ml")
        case .food(let kcal): String(localized: "Undo +\(Format.kcal(kcal)) kcal")
        }
    }
}

private struct DoseCard: View {
    @Environment(AppModel.self) private var model
    let dose: DoseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(Format.time(dose.occurrence.scheduledAt))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(model.appearancePreset.medsEnd)
                Spacer()
                Label(dose.status.label, systemImage: dose.status.symbol)
                    .font(.caption2)
                    .foregroundStyle(color)
            }
            Text(dose.occurrence.medicationName).font(.headline)
            Text(dose.occurrence.dosageText)
                .font(.caption)
                .foregroundStyle(.secondary)
            if dose.status.isResolved {
                Button("Undo") { set(nil) }
                    .buttonStyle(.bordered)
            } else {
                HStack(spacing: 6) {
                    Button { set(.taken) } label: {
                        Label("Taken", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    Button { set(.skipped) } label: {
                        Image(systemName: "forward.end")
                            .frame(minWidth: 30)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Skip")
                }
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
    }

    private var color: Color {
        switch dose.status {
        case .taken: .green
        case .due: .orange
        case .missed: .red
        case .upcoming, .skipped: .secondary
        }
    }

    private func set(_ status: DoseLogStatus?) {
        WKInterfaceDevice.current().play(status == nil ? .click : .success)
        Task { await model.setDose(dose.occurrence, status: status) }
    }
}
