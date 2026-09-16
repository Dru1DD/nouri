import NouriKit
import SwiftUI
import WatchKit

struct WatchRootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        NavigationStack {
            List {
                RingsHeader(today: model.today)
                    .listRowBackground(Color.clear)

                Section {
                    AmountButtons(values: [100, 250, 500], tint: .blue, a11yUnit: "milliliters of water") {
                        model.addFluid($0)
                    }
                } header: {
                    Label("Water", systemImage: "drop.fill").foregroundStyle(.blue)
                }

                Section {
                    AmountButtons(values: [100, 250], tint: .orange, a11yUnit: "kilocalories") {
                        model.addCalories($0)
                    }
                    ForEach(model.presets) { preset in
                        Button {
                            model.addCalories(preset.calories, name: preset.name)
                            WKInterfaceDevice.current().play(.success)
                        } label: {
                            HStack {
                                Text(preset.name).lineLimit(1)
                                Spacer()
                                Text(Format.kcal(preset.calories))
                                    .monospacedDigit()
                                    .foregroundStyle(.orange)
                            }
                        }
                        .accessibilityLabel("Add \(preset.name), \(Format.kcal(preset.calories)) kilocalories")
                    }
                } header: {
                    Label("Calories", systemImage: "flame.fill").foregroundStyle(.orange)
                }

                if !model.medications.isEmpty {
                    Section {
                        NavigationLink { WatchMedicationsView() } label: {
                            MedicationSummaryRow(today: model.today)
                        }
                    } header: {
                        Label("Medications", systemImage: "pills.fill").foregroundStyle(.purple)
                    }
                }
            }
            .navigationTitle("Today")
            .containerBackground(Color.blue.opacity(0.35).gradient, for: .navigation)
        }
    }
}

/// Two activity-style rings: water and calories.
private struct RingsHeader: View {
    let today: DaySummary

    var body: some View {
        HStack(spacing: 12) {
            RingStat(progress: today.hydration, tint: .blue, symbol: "drop.fill",
                     value: Format.liters(today.hydration.value), unit: "L", a11yName: "Water")
            RingStat(progress: today.calories, tint: .orange, symbol: "flame.fill",
                     value: Format.kcal(today.calories.value), unit: "kcal", a11yName: "Calories")
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RingStat: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let progress: GoalProgress
    let tint: Color
    let symbol: String
    let value: String
    let unit: String
    let a11yName: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().stroke(tint.opacity(0.25), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: progress.fraction)
                    .stroke(tint.gradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(reduceMotion ? nil : .spring(duration: 0.5), value: progress.fraction)
                VStack(spacing: 0) {
                    Image(systemName: symbol)
                        .font(.caption2)
                        .foregroundStyle(tint)
                    Text("\(progress.percent)%")
                        .font(.caption2.weight(.semibold).monospacedDigit())
                }
            }
            .frame(width: 58, height: 58)
            Text("\(value) \(unit)")
                .font(.footnote.weight(.semibold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(a11yName)
        .accessibilityValue("\(value) \(unit), \(progress.percent) percent of goal")
    }
}

/// A row of compact tinted "+N" buttons.
private struct AmountButtons: View {
    let values: [Double]
    let tint: Color
    let a11yUnit: String
    let add: (Double) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(values, id: \.self) { value in
                Button {
                    add(value)
                    WKInterfaceDevice.current().play(.success)
                } label: {
                    Text("+\(Int(value))")
                        .font(.body.weight(.semibold).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.bordered)
                .tint(tint)
                .accessibilityLabel("Add \(Int(value)) \(a11yUnit)")
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}

private struct MedicationSummaryRow: View {
    let today: DaySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(today.dosesTaken)/\(today.doses.count) taken")
                    .font(.headline.monospacedDigit())
                Spacer()
                if !today.doses.isEmpty, today.dosesTaken == today.doses.count {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
            }
            if let next = today.nextDose {
                Label("\(Format.time(next.occurrence.scheduledAt)) \(next.occurrence.medicationName)",
                      systemImage: next.status.symbol)
                    .font(.caption)
                    .foregroundStyle(next.status == .due ? .orange : .secondary)
                    .lineLimit(1)
            } else if today.doses.isEmpty {
                Text("No doses today").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

struct WatchMedicationsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List {
            if model.today.doses.isEmpty {
                Text("No doses today").foregroundStyle(.secondary)
            }
            ForEach(model.today.doses) { dose in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(Format.time(dose.occurrence.scheduledAt))
                            .font(.caption.weight(.semibold).monospacedDigit())
                            .foregroundStyle(.purple)
                        Spacer()
                        Label(dose.status.label, systemImage: dose.status.symbol)
                            .font(.caption2)
                            .foregroundStyle(color(dose.status))
                    }
                    Text(dose.occurrence.medicationName).font(.headline)
                    Text(dose.occurrence.dosageText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if dose.status.isResolved {
                        Button("Undo") { set(dose, nil) }
                            .buttonStyle(.bordered)
                    } else {
                        HStack(spacing: 6) {
                            Button { set(dose, .taken) } label: {
                                Label("Taken", systemImage: "checkmark")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            Button { set(dose, .skipped) } label: {
                                Image(systemName: "forward.end")
                                    .frame(minWidth: 30)
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Skip")
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Medications")
        .containerBackground(Color.purple.opacity(0.35).gradient, for: .navigation)
    }

    private func color(_ status: DoseStatus) -> Color {
        switch status {
        case .taken: .green
        case .due: .orange
        case .missed: .red
        case .upcoming, .skipped: .secondary
        }
    }

    private func set(_ dose: DoseItem, _ status: DoseLogStatus?) {
        WKInterfaceDevice.current().play(status == nil ? .click : .success)
        Task { await model.setDose(dose.occurrence, status: status) }
    }
}
