import NouriKit
import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model
    @State private var sheet: Sheet?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Sheet: Identifiable {
        case fluid, food
        case editFluid(FluidItem)
        case editFood(FoodItem)

        var id: String {
            switch self {
            case .fluid: "fluid"
            case .food: "food"
            case .editFluid(let f): "fluid-\(f.id)"
            case .editFood(let f): "food-\(f.id)"
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                hydrationSection
                caloriesSection
                medicationsSection
                activitySection
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink { HistoryView() } label: {
                        Label("History", systemImage: "calendar")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink { SettingsView() } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .sheet(item: $sheet) { sheet in
                switch sheet {
                case .fluid: FluidForm()
                case .food: FoodForm()
                case .editFluid(let item): FluidForm(editing: item)
                case .editFood(let item): FoodForm(editing: item)
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let added = model.lastAdded {
                    UndoBanner(added: added)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? nil : .snappy, value: model.lastAdded)
        }
    }

    private var today: DaySummary { model.today }

    // MARK: Sections

    private var hydrationSection: some View {
        Section {
            ProgressRow(
                title: "Hydration",
                symbol: "drop.fill",
                tint: .blue,
                value: String(localized: "\(Format.liters(today.hydration.value)) / \(Format.liters(today.hydration.goal)) L"),
                progress: today.hydration,
                identifier: "hydration-total"
            )
            QuickAddRow(values: [100, 250, 500], idPrefix: "add-water", a11yLabel: { String(localized: "Add \($0) milliliters") }) { model.addFluid($0) } more: {
                sheet = .fluid
            }
            if let imported = model.imported, imported.waterML > 0 {
                Label("\(Format.ml(imported.waterML)) ml more in Apple Health from other apps", systemImage: "heart.text.square")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var caloriesSection: some View {
        Section {
            ProgressRow(
                title: "Calories",
                symbol: "flame.fill",
                tint: .orange,
                value: String(localized: "\(Format.kcal(today.calories.value)) / \(Format.kcal(today.calories.goal)) kcal"),
                progress: today.calories,
                identifier: "calories-total"
            )
            QuickAddRow(values: [50, 100, 250, 500], idPrefix: "add-kcal", a11yLabel: { String(localized: "Add \($0) kilocalories") }) { model.addCalories($0) } more: {
                sheet = .food
            }
            if !model.presets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(model.presets) { preset in
                            Button("\(preset.name) · \(Format.kcal(preset.calories))") {
                                model.addCalories(preset.calories, name: preset.name)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Add \(preset.name), \(Format.kcal(preset.calories)) kilocalories")
                        }
                    }
                }
            }
            if let imported = model.imported, imported.kcal > 0 {
                Label("\(Format.kcal(imported.kcal)) kcal more in Apple Health from other apps", systemImage: "heart.text.square")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var medicationsSection: some View {
        Section {
            if today.doses.isEmpty {
                NavigationLink { MedicationsView() } label: {
                    Label("Add a medication reminder", systemImage: "pills")
                }
            } else {
                ProgressRow(
                    title: "Medications",
                    symbol: "pills.fill",
                    tint: .purple,
                    value: String(localized: "\(today.dosesTaken) / \(today.doses.count) taken"),
                    progress: today.medicationProgress,
                    identifier: "medications-total"
                )
                ForEach(today.doses) { DoseRow(dose: $0) }
            }
        } header: {
            HStack {
                Text("Medications")
                Spacer()
                NavigationLink("Manage") { MedicationsView() }
                    .font(.footnote)
            }
        }
    }

    private var activitySection: some View {
        Section("Recent Activity") {
            if today.activity.isEmpty {
                Text("Nothing logged yet today.").foregroundStyle(.secondary)
            }
            ForEach(today.activity) { item in
                Button {
                    switch item {
                    case .fluid(let f): sheet = .editFluid(f)
                    case .food(let f): sheet = .editFood(f)
                    case .dose: break
                    }
                } label: {
                    ActivityRow(item: item)
                }
                .foregroundStyle(.primary)
                .disabled({ if case .dose = item { true } else { false } }())
                .accessibilityHint({ if case .dose = item { "" } else { String(localized: "Opens the entry for editing") } }())
                .swipeActions {
                    switch item {
                    case .fluid(let f):
                        Button("Delete", role: .destructive) { model.deleteEntry(id: f.id) }
                    case .food(let f):
                        Button("Delete", role: .destructive) { model.deleteEntry(id: f.id) }
                    case .dose:
                        EmptyView()
                    }
                }
            }
        }
    }
}

// MARK: - Rows

struct ProgressRow: View {
    let title: LocalizedStringKey
    let symbol: String
    let tint: Color
    let value: String
    let progress: GoalProgress
    let identifier: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Label(title, systemImage: symbol)
                    .font(.headline)
                    .foregroundStyle(tint)
                Spacer()
                Text("\(progress.percent)%")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Text(value)
                .font(.title2.weight(.semibold).monospacedDigit())
            ProgressView(value: progress.fraction)
                .tint(tint)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(title))
        .accessibilityValue("\(value), \(progress.percent) percent of goal")
        .accessibilityIdentifier(identifier)
    }
}

struct QuickAddRow: View {
    let values: [Double]
    let idPrefix: String
    let a11yLabel: (Int) -> String
    let add: (Double) -> Void
    let more: () -> Void
    @State private var taps = 0

    var body: some View {
        HStack {
            ForEach(values, id: \.self) { value in
                Button {
                    add(value)
                    taps += 1
                } label: {
                    Text("+\(Int(value))")
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .accessibilityLabel(a11yLabel(Int(value)))
                .accessibilityIdentifier("\(idPrefix)-\(Int(value))")
            }
            Button { more() } label: {
                Image(systemName: "ellipsis")
                    .frame(minWidth: 24, minHeight: 20)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Custom amount")
            .accessibilityIdentifier("\(idPrefix)-custom")
        }
        .listRowSeparator(.hidden)
        .sensoryFeedback(.success, trigger: taps)
    }
}

struct DoseRow: View {
    @Environment(AppModel.self) private var model
    let dose: DoseItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dose.occurrence.medicationName).font(.body.weight(.medium))
                Text("\(Format.time(dose.occurrence.scheduledAt)) · \(dose.occurrence.dosageText)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                StatusLabel(status: dose.status)
            }
            Spacer()
            if !dose.status.isResolved {
                Button("Taken") { Task { await model.setDose(dose.occurrence, status: .taken) } }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("dose-taken-\(dose.occurrence.medicationName)")
            }
        }
        .accessibilityElement(children: .combine)
        .swipeActions {
            if dose.status.isResolved {
                Button("Undo") { Task { await model.setDose(dose.occurrence, status: nil) } }
            } else {
                Button("Skip") { Task { await model.setDose(dose.occurrence, status: .skipped) } }
                    .tint(.gray)
                Button("Snooze") { Task { await model.snooze(dose.occurrence) } }
                    .tint(.indigo)
            }
        }
    }
}

struct StatusLabel: View {
    let status: DoseStatus

    var body: some View {
        Label(status.label, systemImage: status.symbol)
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .accessibilityIdentifier("dose-status")
    }

    private var color: Color {
        switch status {
        case .taken: .green
        case .skipped, .upcoming: .secondary
        case .due: .orange
        case .missed: .red
        }
    }
}

struct ActivityRow: View {
    let item: ActivityItem

    var body: some View {
        HStack {
            Image(systemName: symbol)
                .foregroundStyle(.secondary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(title)
                Text(Format.time(item.date)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(amount).monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }

    private var symbol: String {
        switch item {
        case .fluid(let f): f.beverage.symbol
        case .food: "fork.knife"
        case .dose(let d): d.status.symbol
        }
    }

    private var title: String {
        switch item {
        case .fluid(let f): f.beverage.title
        case .food(let f): f.displayName
        case .dose(let d): d.occurrence.medicationName
        }
    }

    private var amount: String {
        switch item {
        case .fluid(let f): f.calories > 0
            ? String(localized: "+\(Format.ml(f.amountML)) ml · \(Format.kcal(f.calories)) kcal")
            : String(localized: "+\(Format.ml(f.amountML)) ml")
        case .food(let f): String(localized: "+\(Format.kcal(f.calories)) kcal")
        case .dose(let d): d.status.label
        }
    }
}

/// "Added 250 ml · Undo", shown for a few seconds after a quick add.
struct UndoBanner: View {
    @Environment(AppModel.self) private var model
    let added: AppModel.LastAdded

    private var text: String {
        switch added.kind {
        case .fluid(let ml, let beverage):
            String(localized: "Added \(Format.ml(ml)) ml · \(beverage.title)")
        case .food(let kcal):
            String(localized: "Added \(Format.kcal(kcal)) kcal")
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            Text(text)
                .font(.subheadline.weight(.medium))
                .lineLimit(2)
            Spacer()
            Button("Undo") { model.undoLastAdd() }
                .font(.subheadline.weight(.semibold))
                .accessibilityIdentifier("undo-add")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: .capsule)
        .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
        .task(id: added.id) {
            AccessibilityNotification.Announcement(text).post()
            try? await Task.sleep(for: .seconds(5))
            model.dismissUndo(id: added.id)
        }
    }
}
