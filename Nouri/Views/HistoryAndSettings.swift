import NouriKit
import SwiftUI

struct HistoryView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        List(model.history(days: 30), id: \.day) { day in
            VStack(alignment: .leading, spacing: 4) {
                Text(day.day.formatted(.dateTime.weekday(.wide).day().month()))
                    .font(.headline)
                HStack(spacing: 16) {
                    Label("\(Format.liters(day.hydration.value)) L", systemImage: "drop.fill")
                    Label("\(Format.kcal(day.calories.value)) kcal", systemImage: "flame.fill")
                    if !day.doses.isEmpty {
                        Label("\(day.dosesTaken)/\(day.doses.count)", systemImage: "pills.fill")
                    }
                }
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
        .navigationTitle("History")
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var presetName = ""
    @State private var presetCalories: Double?

    var body: some View {
        Form {
            Section("Daily Goals") {
                Stepper(value: Binding(get: { model.hydrationGoal },
                                       set: { model.setGoals(hydrationML: $0, calories: model.calorieGoal) }), in: 250...10_000, step: 250) {
                    LabeledContent("Water", value: String(localized: "\(Format.liters(model.hydrationGoal)) L"))
                }
                Stepper(value: Binding(get: { model.calorieGoal },
                                       set: { model.setGoals(hydrationML: model.hydrationGoal, calories: $0) }), in: 500...10_000, step: 50) {
                    LabeledContent("Calories", value: String(localized: "\(Format.kcal(model.calorieGoal)) kcal"))
                }
            }

            Section("Calorie Presets") {
                ForEach(model.presets) { preset in
                    LabeledContent(preset.name, value: String(localized: "\(Format.kcal(preset.calories)) kcal"))
                }
                .onDelete { offsets in
                    offsets.map { model.presets[$0].id }.forEach(model.deletePreset)
                }
                HStack {
                    TextField("Name", text: $presetName)
                    TextField("kcal", value: $presetCalories, format: .number)
                        .keyboardType(.numberPad)
                        .frame(width: 70)
                    Button("Add") {
                        model.addPreset(name: presetName, calories: presetCalories ?? 0)
                        presetName = ""
                        presetCalories = nil
                    }
                    .disabled(presetName.trimmingCharacters(in: .whitespaces).isEmpty || (presetCalories ?? 0) <= 0)
                }
            }

            Section {
                NavigationLink("Medications") { MedicationsView() }
            }

            if model.isHealthAvailable {
                Section {
                    if model.healthConnected {
                        Label("Connected to Apple Health", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button("Connect Apple Health") { Task { await model.connectHealth() } }
                    }
                } header: {
                    Text("Apple Health")
                } footer: {
                    Text("Nouri saves water and calories you log to Health, and shows amounts other apps logged separately. You can change access anytime in the Health app.")
                }
            }

            Section {
                Text("Nouri reminds you about medications you configure. It does not provide medical advice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
