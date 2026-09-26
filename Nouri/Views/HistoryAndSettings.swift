import NouriKit
import SwiftUI

struct HistoryView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        let days = model.history(days: 30)
        let isEmpty = days.allSatisfy { $0.fluids.isEmpty && $0.foods.isEmpty && $0.dosesTaken == 0 }
        List {
            if isEmpty {
                ContentUnavailableView {
                    Label("No activity yet", systemImage: "calendar")
                } description: {
                    Text("Log a drink on Today to start your history.")
                }
            } else {
                ForEach(days, id: \.day) { day in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day.day.formatted(.dateTime.weekday(.wide).day().month()))
                            .font(.headline)
                        HStack(spacing: 16) {
                            Label("\(Format.liters(day.hydration.value)) L", systemImage: "drop.fill")
                            Label("\(Format.kcal(day.calories.value)) kcal", systemImage: "fork.knife")
                            if day.alcoholML > 0 {
                                Label("\(Format.ml(day.alcoholML)) ml", systemImage: "wineglass.fill")
                                    .accessibilityLabel("Alcohol \(Format.ml(day.alcoholML)) milliliters")
                            }
                            if !day.doses.isEmpty {
                                Label("\(day.dosesTaken)/\(day.doses.count)", systemImage: "pills.fill")
                            }
                        }
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
        .navigationTitle("History")
    }
}

struct SettingsView: View {
    @Environment(AppModel.self) private var model
    @State private var presetName = ""
    @State private var presetCalories: Double?
    @State private var confirmDelete = false
    @State private var removeFromHealth = false
    @State private var exportURL: URL?
    @State private var showExport = false

    private let intervalOptions = [60, 120, 180, 240]

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

            Section {
                Toggle("Hydration reminders", isOn: Binding(
                    get: { model.hydrationRemindersEnabled },
                    set: { enabled in Task { await model.setHydrationReminders(enabled: enabled) } }
                ))
                if model.hydrationRemindersEnabled {
                    Picker("Every", selection: Binding(
                        get: { model.hydrationReminderIntervalMinutes },
                        set: { minutes in Task { await model.setHydrationReminders(enabled: true, intervalMinutes: minutes) } }
                    )) {
                        ForEach(intervalOptions, id: \.self) { minutes in
                            Text(minutes >= 60 ? "\(minutes / 60) h" : "\(minutes) min").tag(minutes)
                        }
                    }
                    DatePicker(
                        "Quiet from",
                        selection: Binding(
                            get: { minutesBinding(model.quietHoursStartMinutes) },
                            set: { date in
                                let mins = minutes(from: date)
                                Task { await model.setHydrationReminders(enabled: true, quietStartMinutes: mins) }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    DatePicker(
                        "Quiet until",
                        selection: Binding(
                            get: { minutesBinding(model.quietHoursEndMinutes) },
                            set: { date in
                                let mins = minutes(from: date)
                                Task { await model.setHydrationReminders(enabled: true, quietEndMinutes: mins) }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
                if model.notificationsAllowed == false {
                    Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                        Label("Notifications are off. Open Settings to enable them.", systemImage: "exclamationmark.triangle.fill")
                    }
                    .font(.footnote)
                    .foregroundStyle(.orange)
                }
            } header: {
                Text("Reminders")
            } footer: {
                Text("Reminders pause after you reach your daily water goal, and never fire during quiet hours.")
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
                Button("Export Data") { exportData() }
                    .accessibilityIdentifier("export-data")
                Button("Delete All Data", role: .destructive) {
                    removeFromHealth = false
                    confirmDelete = true
                }
                .accessibilityIdentifier("delete-all-data")
            } header: {
                Text("Data")
            } footer: {
                Text("Export creates a JSON file on this device. Delete All removes Nouri data on iPhone and syncs deletions to Apple Watch.")
            }

            Section {
                Text("Nouri reminds you about medications and hydration you configure. It does not provide medical advice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $confirmDelete) {
            NavigationStack {
                Form {
                    Section {
                        Text("This permanently removes drinks, food, medications, presets and reminder settings on this device. Your Apple Watch will receive the deletions.")
                    }
                    if model.isHealthAvailable {
                        Section {
                            Toggle("Also remove from Apple Health", isOn: $removeFromHealth)
                        } footer: {
                            Text("Only samples Nouri created are removed. Data from other apps is left alone.")
                        }
                    }
                }
                .navigationTitle("Delete All Data")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { confirmDelete = false }
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", role: .destructive) {
                            confirmDelete = false
                            Task { await model.deleteAllData(removeFromHealth: removeFromHealth) }
                        }
                        .accessibilityIdentifier("confirm-delete-all")
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showExport) {
            if let exportURL {
                ShareLink(item: exportURL) {
                    Label("Share Export", systemImage: "square.and.arrow.up")
                }
                .padding()
                .presentationDetents([.medium])
            }
        }
    }

    private func minutesBinding(_ minutes: Int) -> Date {
        Calendar.current.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: Date()) ?? Date()
    }

    private func minutes(from date: Date) -> Int {
        let c = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (c.hour ?? 0) * 60 + (c.minute ?? 0)
    }

    private func exportData() {
        do {
            let data = try model.exportDataJSON()
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("nouri-export.json")
            try data.write(to: url, options: .atomic)
            exportURL = url
            showExport = true
        } catch {
            // Surface via AppModel if we add lastError; for now silent is acceptable.
        }
    }
}
