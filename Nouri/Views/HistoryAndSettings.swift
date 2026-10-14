import NouriKit
import SwiftUI

struct HistoryView: View {
    @Environment(AppModel.self) private var model
    @State private var month = Date()

    private var calendar: Calendar { Calendar.autoupdatingCurrent }

    var body: some View {
        let days = monthDays()
        VStack(spacing: 12) {
            HStack {
                Button { shiftMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Previous month")
                Spacer()
                Text(month.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                Spacer()
                Button { shiftMonth(1) } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel("Next month")
                .disabled(calendar.isDate(month, equalTo: Date(), toGranularity: .month))
            }
            .padding(.horizontal)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 8) {
                ForEach(weekdaySymbols(), id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                    if let day {
                        let summary = model.summary(for: day)
                        NavigationLink {
                            DayLogView(day: day)
                        } label: {
                            CalendarDayCell(day: day, summary: summary, isToday: calendar.isDateInToday(day), preset: model.appearancePreset)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 16) {
                Label("Drink logged", systemImage: "circle.fill")
                    .foregroundStyle(model.appearancePreset.waterEnd)
                Label("Dose taken", systemImage: "circle.fill")
                    .foregroundStyle(model.appearancePreset.medsEnd)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(.top, 8)
        .themedBackground(model.appearancePreset)
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func shiftMonth(_ delta: Int) {
        month = calendar.date(byAdding: .month, value: delta, to: month) ?? month
    }

    private func weekdaySymbols() -> [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        return Array(symbols[start...]) + Array(symbols[..<start])
    }

    private func monthDays() -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let pad = (firstWeekday - calendar.firstWeekday + 7) % 7
        let count = calendar.range(of: .day, in: .month, for: month)?.count ?? 0
        var days: [Date?] = Array(repeating: nil, count: pad)
        for day in 0..<count {
            days.append(calendar.date(byAdding: .day, value: day, to: interval.start))
        }
        return days
    }
}

private struct CalendarDayCell: View {
    let day: Date
    let summary: DaySummary
    let isToday: Bool
    let preset: AppearancePreset
    private var isFuture: Bool { day > Date() && !Calendar.autoupdatingCurrent.isDateInToday(day) }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.autoupdatingCurrent.component(.day, from: day))")
                .font(.body.weight(isToday ? .bold : .regular).monospacedDigit())
                .frame(width: 32, height: 32)
                .background(isToday ? AnyShapeStyle(.tint.opacity(0.18)) : AnyShapeStyle(.clear), in: Circle())
            HStack(spacing: 3) {
                if summary.hydration.value > 0 {
                    Circle().fill(preset.waterEnd).frame(width: 5, height: 5)
                }
                if summary.dosesTaken > 0 {
                    Circle().fill(preset.medsEnd).frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
        .opacity(isFuture && summary.doses.isEmpty ? 0.35 : 1)
        .accessibilityLabel(day.formatted(.dateTime.weekday(.wide).month(.wide).day()))
        .accessibilityValue(value)
        .accessibilityHint("Shows what was logged that day")
    }

    private var value: String {
        var parts: [String] = []
        if summary.hydration.value > 0 {
            parts.append(String(localized: "\(Format.liters(summary.hydration.value)) L"))
        }
        if !summary.doses.isEmpty {
            parts.append(String(localized: "\(summary.dosesTaken) of \(summary.doses.count) doses"))
        }
        return parts.isEmpty ? String(localized: "No activity") : parts.joined(separator: ", ")
    }
}

struct DayLogView: View {
    @Environment(AppModel.self) private var model
    let day: Date

    var body: some View {
        let summary = model.summary(for: day)
        List {
            Section {
                LabeledContent("Water") {
                    Text("\(Format.liters(summary.hydration.value)) / \(Format.liters(summary.hydration.goal)) L")
                        .monospacedDigit()
                }
                if !summary.doses.isEmpty {
                    LabeledContent("Medications") {
                        Text("\(summary.dosesTaken) / \(summary.doses.count)")
                            .monospacedDigit()
                    }
                }
                if model.caloriesEnabled {
                    LabeledContent("Calories") {
                        Text("\(Format.kcal(summary.calories.value)) kcal")
                            .monospacedDigit()
                    }
                }
            }

            if !summary.doses.isEmpty {
                Section("Medications") {
                    ForEach(summary.doses) { dose in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dose.occurrence.medicationName)
                                Text(timeLine(dose))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(dose.status.label)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }

            if !summary.fluids.isEmpty {
                Section("Drinks") {
                    ForEach(summary.fluids) { drink in
                        HStack {
                            Label(drink.beverage.title, systemImage: drink.beverage.symbol)
                            Spacer()
                            Text("\(Format.time(drink.timestamp)) · \(Format.ml(drink.amountML)) ml")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }

            if model.caloriesEnabled, !summary.foods.isEmpty {
                Section("Food") {
                    ForEach(summary.foods) { food in
                        HStack {
                            Text(food.displayName)
                            Spacer()
                            Text("\(Format.time(food.timestamp)) · \(Format.kcal(food.calories)) kcal")
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if summary.fluids.isEmpty && summary.doses.isEmpty && summary.foods.isEmpty {
                ContentUnavailableView {
                    Label("Nothing logged", systemImage: "calendar")
                } description: {
                    Text("No drinks or doses on this day.")
                }
            }
        }
        .themedBackground(model.appearancePreset)
        .navigationTitle(day.formatted(.dateTime.weekday(.wide).day().month()))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func timeLine(_ dose: DoseItem) -> String {
        let scheduled = Format.time(dose.occurrence.scheduledAt)
        if let logged = dose.loggedAt {
            return String(localized: "Scheduled \(scheduled) · logged \(Format.time(logged))")
        }
        return String(localized: "Scheduled \(scheduled)")
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
    @State private var analyticsURL: URL?
    @State private var showAnalytics = false

    private let intervalOptions = [30, 60, 120, 180, 240]

    var body: some View {
        Form {
            Section("Daily Goals") {
                Stepper(value: Binding(get: { model.hydrationGoal },
                                       set: { model.setGoals(hydrationML: $0, calories: model.calorieGoal) }), in: 250...10_000, step: 250) {
                    LabeledContent("Water", value: String(localized: "\(Format.liters(model.hydrationGoal)) L"))
                }
                // Calories are hidden for now (no toggle); `-calories-enabled` turns them on for UI tests.
                if model.caloriesEnabled {
                    Stepper(value: Binding(get: { model.calorieGoal },
                                           set: { model.setGoals(hydrationML: model.hydrationGoal, calories: $0) }), in: 500...10_000, step: 50) {
                        LabeledContent("Calories", value: String(localized: "\(Format.kcal(model.calorieGoal)) kcal"))
                    }
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
                        "Night quiet from",
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
                        "Night quiet until",
                        selection: Binding(
                            get: { minutesBinding(model.quietHoursEndMinutes) },
                            set: { date in
                                let mins = minutes(from: date)
                                Task { await model.setHydrationReminders(enabled: true, quietEndMinutes: mins) }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    Toggle("Midday break", isOn: Binding(
                        get: { model.daytimeQuietEnabled },
                        set: { enabled in Task { await model.setDaytimeQuiet(enabled: enabled) } }
                    ))
                    if model.daytimeQuietEnabled {
                        DatePicker(
                            "Break from",
                            selection: Binding(
                                get: { minutesBinding(model.daytimeQuietStartMinutes) },
                                set: { date in Task { await model.setDaytimeQuiet(startMinutes: minutes(from: date)) } }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        DatePicker(
                            "Break until",
                            selection: Binding(
                                get: { minutesBinding(model.daytimeQuietEndMinutes) },
                                set: { date in Task { await model.setDaytimeQuiet(endMinutes: minutes(from: date)) } }
                            ),
                            in: minutesBinding(min(model.daytimeQuietStartMinutes + 15, 23 * 60 + 59))...,
                            displayedComponents: .hourAndMinute
                        )
                    }
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
                Text("Reminders pause once today's water goal is met and start again tomorrow. They never fire during night quiet hours or the midday break.")
            }

            if model.caloriesEnabled {
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
            }

            Section {
                Picker("Palette", selection: Binding(
                    get: { model.appearancePreset },
                    set: { model.setAppearancePreset($0) }
                )) {
                    ForEach(AppearancePreset.allCases) { preset in
                        HStack(spacing: 12) {
                            HStack(spacing: -6) {
                                Circle().fill(preset.waterGradient).frame(width: 22, height: 22)
                                Circle().fill(preset.medsGradient).frame(width: 22, height: 22)
                                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
                            }
                            .accessibilityHidden(true)
                            Text(preset.title)
                        }
                        .tag(preset)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Appearance")
            } footer: {
                Text("Colors for the app, widgets and Apple Watch.")
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
                    Text(model.caloriesEnabled
                         ? "Nouri saves water and calories you log to Health, and shows amounts other apps logged separately. You can change access anytime in the Health app."
                         : "Nouri saves water you log to Health, and shows amounts other apps logged separately. You can change access anytime in the Health app.")
                }
            }

            Section {
                Button("Export Data") { exportData() }
                    .accessibilityIdentifier("export-data")
                Button("Share beta stats") { exportAnalytics() }
                    .accessibilityIdentifier("share-beta-stats")
                Button("Delete All Data", role: .destructive) {
                    removeFromHealth = false
                    confirmDelete = true
                }
                .accessibilityIdentifier("delete-all-data")
            } header: {
                Text("Data")
            } footer: {
                Text("Export creates a JSON file on this device. Share beta stats is anonymous counters only (no amounts or names) and leaves the device only if you share the file. Delete All removes Nouri data on iPhone and syncs deletions to Apple Watch.")
            }

            Section {
                Text("Nouri reminds you about medications and hydration you configure. It does not provide medical advice.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .themedBackground(model.appearancePreset)
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
                .themedBackground(model.appearancePreset)
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
        .sheet(isPresented: $showAnalytics) {
            if let analyticsURL {
                ShareLink(item: analyticsURL) {
                    Label("Share Beta Stats", systemImage: "square.and.arrow.up")
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

    private func exportAnalytics() {
        do {
            let data = try model.exportAnalyticsJSON()
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("nouri-beta-stats.json")
            try data.write(to: url, options: .atomic)
            analyticsURL = url
            showAnalytics = true
        } catch {}
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
