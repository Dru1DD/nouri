import NouriKit
import SwiftUI

struct MedicationsView: View {
    @Environment(AppModel.self) private var model
    @State private var editing: MedicationInfo?

    var body: some View {
        List {
            if model.notificationsAllowed == false {
                Section {
                    Label("Notifications are off, so reminders can't be delivered.", systemImage: "bell.slash")
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        Link("Open Settings", destination: url)
                    }
                }
            }
            Section {
                ForEach(model.medications) { med in
                    Button { editing = med } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(med.name).foregroundStyle(.primary)
                            Text(summary(med)).font(.subheadline).foregroundStyle(.secondary)
                            if !med.isActive {
                                Label("Paused", systemImage: "pause.circle").font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let ids = offsets.map { model.medications[$0].id }
                    Task { for id in ids { await model.deleteMedication(id: id) } }
                }
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(model.scheduledReminderCount) upcoming reminders scheduled")
                        .accessibilityIdentifier("reminder-count")
                    Text("Nouri only reminds you about medications you add yourself. It does not give medical advice.")
                }
            }
        }
        .overlay {
            if model.medications.isEmpty {
                ContentUnavailableView("No Medications", systemImage: "pills",
                                       description: Text("Add a medication to get reminders."))
            }
        }
        .navigationTitle("Medications")
        .toolbar {
            Button {
                editing = MedicationInfo(name: "", dosage: 1, unit: "tablet",
                                         schedule: MedicationSchedule(times: [TimeOfDay(hour: 8, minute: 0)]))
            } label: {
                Label("Add Medication", systemImage: "plus")
            }
            .accessibilityIdentifier("add-medication")
        }
        .sheet(item: $editing) { MedicationEditor(medication: $0) }
    }

    private func summary(_ med: MedicationInfo) -> String {
        let cal = Calendar.current
        let times = med.schedule.times.sorted().compactMap { t in
            cal.date(bySettingHour: t.hour, minute: t.minute, second: 0, of: .now).map(Format.time)
        }
        let days = med.schedule.weekdays.isEmpty
            ? "Every day"
            : med.schedule.weekdays.sorted().map { cal.shortWeekdaySymbols[$0 - 1] }.joined(separator: ", ")
        return "\(med.dosageText) · \(times.joined(separator: ", ")) · \(days)"
    }
}

struct MedicationEditor: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @State private var draft: MedicationInfo
    @State private var times: [Date]
    private let isNew: Bool

    init(medication: MedicationInfo) {
        _draft = State(initialValue: medication)
        isNew = medication.name.isEmpty
        let cal = Calendar.current
        _times = State(initialValue: medication.schedule.times.sorted().compactMap {
            cal.date(bySettingHour: $0.hour, minute: $0.minute, second: 0, of: .now)
        })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $draft.name)
                        .accessibilityIdentifier("medication-name")
                    HStack {
                        TextField("Dose", value: $draft.dosage, format: .number)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Dose amount")
                        TextField("Unit", text: $draft.unit)
                            .accessibilityLabel("Dose unit")
                    }
                }
                Section("Times") {
                    ForEach(times.indices, id: \.self) { index in
                        DatePicker("Reminder \(index + 1)", selection: $times[index], displayedComponents: .hourAndMinute)
                    }
                    .onDelete { times.remove(atOffsets: $0) }
                    Button("Add Time") {
                        times.append(times.last?.addingTimeInterval(4 * 3600) ?? .now)
                    }
                }
                Section("Days") {
                    WeekdayPicker(selection: $draft.schedule.weekdays)
                }
                Section {
                    TextField("Notes", text: $draft.notes, axis: .vertical)
                    Toggle("Reminders active", isOn: $draft.isActive)
                }
            }
            .navigationTitle(isNew ? "New Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var med = draft
                        med.name = med.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        let cal = Calendar.current
                        med.schedule.times = times.map {
                            TimeOfDay(hour: cal.component(.hour, from: $0), minute: cal.component(.minute, from: $0))
                        }
                        Task {
                            await model.saveMedication(med)
                            dismiss()
                        }
                    }
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty || times.isEmpty || draft.dosage <= 0)
                    .accessibilityIdentifier("medication-save")
                }
            }
        }
    }
}

/// Empty selection means every day.
struct WeekdayPicker: View {
    @Binding var selection: Set<Int>

    var body: some View {
        let cal = Calendar.current
        let order = (0..<7).map { (cal.firstWeekday - 1 + $0) % 7 + 1 }
        HStack {
            ForEach(order, id: \.self) { day in
                let isOn = selection.isEmpty || selection.contains(day)
                Button {
                    toggle(day)
                } label: {
                    Text(cal.veryShortWeekdaySymbols[day - 1])
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(isOn ? Color.accentColor.opacity(0.2) : .clear, in: .circle)
                        .overlay(Circle().strokeBorder(isOn ? Color.accentColor : .secondary))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(cal.weekdaySymbols[day - 1])
                .accessibilityAddTraits(isOn ? .isSelected : [])
            }
        }
    }

    private func toggle(_ day: Int) {
        var days = selection.isEmpty ? Set(1...7) : selection
        if days.contains(day) { days.remove(day) } else { days.insert(day) }
        // All days selected or none selected both mean "every day".
        selection = days.count == 7 || days.isEmpty ? [] : days
    }
}
