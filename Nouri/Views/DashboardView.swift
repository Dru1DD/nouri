import NouriKit
import SwiftUI

struct DashboardView: View {
    @Environment(AppModel.self) private var model
    @State private var sheet: Sheet?

    private enum Sheet: String, Identifiable {
        case fluid, food
        var id: String { rawValue }
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
                case .fluid: AddFluidView()
                case .food: AddFoodView()
                }
            }
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
                value: "\(Format.liters(today.hydration.value)) / \(Format.liters(today.hydration.goal)) L",
                progress: today.hydration,
                identifier: "hydration-total"
            )
            QuickAddRow(values: [100, 250, 500], unit: "ml", idPrefix: "add-water") { model.addFluid($0) } more: {
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
                value: "\(Format.kcal(today.calories.value)) / \(Format.kcal(today.calories.goal)) kcal",
                progress: today.calories,
                identifier: "calories-total"
            )
            QuickAddRow(values: [50, 100, 250, 500], unit: "kcal", idPrefix: "add-kcal") { model.addCalories($0) } more: {
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
                    value: "\(today.dosesTaken) / \(today.doses.count) taken",
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
                ActivityRow(item: item)
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
    let title: String
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
        .accessibilityLabel(title)
        .accessibilityValue("\(value), \(progress.percent) percent of goal")
        .accessibilityIdentifier(identifier)
    }
}

struct QuickAddRow: View {
    let values: [Double]
    let unit: String
    let idPrefix: String
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
                .accessibilityLabel("Add \(Int(value)) \(unit == "ml" ? "milliliters" : "kilocalories")")
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
        case .food(let f): f.name
        case .dose(let d): d.occurrence.medicationName
        }
    }

    private var amount: String {
        switch item {
        case .fluid(let f): f.calories > 0 ? "+\(Format.ml(f.amountML)) ml · \(Format.kcal(f.calories)) kcal" : "+\(Format.ml(f.amountML)) ml"
        case .food(let f): "+\(Format.kcal(f.calories)) kcal"
        case .dose(let d): d.status.label
        }
    }
}
