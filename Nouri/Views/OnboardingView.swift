import NouriKit
import SwiftUI

/// Six steps: Welcome → water goal → first medication → reminders → Health → widget.
/// Buttons only (no swipe), so every step's choice is saved when leaving it.
struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var step = 0
    @State private var forward = true
    @State private var goal: Double = 2500
    @State private var enableReminders = true
    @State private var intervalMinutes = 120
    @State private var addMedication = false
    @State private var finished = false

    private let lastStep = 5
    private var preset: AppearancePreset { model.appearancePreset }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            ZStack {
                stepView
                    .id(step)
                    .transition(reduceMotion ? .opacity : .asymmetric(
                        insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
                    ))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 24)
            .clipped()

            Button {
                Task { await advance() }
            } label: {
                Text(primaryTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(step == 2 && model.medications.isEmpty ? .secondary : preset.waterEnd)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)
            .accessibilityIdentifier("onboarding-continue")
        }
        .background(background.ignoresSafeArea())
        .sensoryFeedback(.selection, trigger: step)
        .sensoryFeedback(.success, trigger: finished)
        .sheet(isPresented: $addMedication) {
            MedicationEditor(medication: MedicationInfo(
                name: "", dosage: 1, unit: String(localized: "tablet"),
                schedule: MedicationSchedule(times: [TimeOfDay(hour: 8, minute: 0)])
            ))
        }
        .interactiveDismissDisabled()
        .onAppear {
            goal = model.hydrationGoal
            intervalMinutes = model.hydrationReminderIntervalMinutes
        }
    }

    // MARK: - Chrome

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                go(to: step - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .opacity(step > 0 ? 1 : 0)
            .disabled(step == 0)
            .accessibilityHidden(step == 0)
            .accessibilityLabel("Back")
            .accessibilityIdentifier("onboarding-back")

            HStack(spacing: 4) {
                ForEach(0...lastStep, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? AnyShapeStyle(preset.waterGradient) : AnyShapeStyle(Color.secondary.opacity(0.25)))
                        .frame(height: 4)
                }
            }
            .animation(reduceMotion ? nil : .snappy, value: step)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Step \(step + 1) of \(lastStep + 1)")
            .accessibilityIdentifier("onboarding-progress")

            Button("Skip") { Task { await skip() } }
                .font(.subheadline)
                .opacity(step < lastStep ? 1 : 0)
                .disabled(step == lastStep)
                .accessibilityIdentifier("onboarding-skip")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var background: some View {
        LinearGradient(
            colors: [step == 2 ? preset.medsStart.opacity(0.18) : preset.waterStart.opacity(0.18), preset.background ?? Color(.systemBackground)],
            startPoint: .top, endPoint: .center
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: step)
    }

    private var primaryTitle: LocalizedStringKey {
        switch step {
        case 0: "Let's start"
        case 2: model.medications.isEmpty ? "Not now" : "Continue"
        case lastStep: "Get Started"
        default: "Continue"
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case 0: welcomeStep
        case 1: goalStep
        case 2: medicationStep
        case 3: remindersStep
        case 4: healthStep
        default: widgetStep
        }
    }

    // MARK: - Steps

    private var welcomeStep: some View {
        StepLayout(title: "Water and medications, in one place",
                   subtitle: "Log a drink in a tap, never miss a dose. Takes a minute to set up.") {
            AnimatedRings(preset: preset, water: 0.72, meds: 0.5, reduceMotion: reduceMotion) {
                AppIconView()
            }
            .frame(width: 190, height: 190)
        } content: {
            VStack(alignment: .leading, spacing: 14) {
                FeatureRow(symbol: "drop.fill", tint: preset.waterStart, text: "One tap logging, on iPhone and Apple Watch")
                FeatureRow(symbol: "pills.fill", tint: preset.medsStart, text: "Dose reminders with Taken, Snooze and Skip")
                FeatureRow(symbol: "lock.fill", tint: .secondary, text: "Stays on your devices. No account.")
            }
        }
    }

    private var goalStep: some View {
        let progress = GoalProgress(value: goal, goal: 4000)
        return StepLayout(title: "Your daily water goal",
                          subtitle: "Most adults need 2–3 L a day. You can change it anytime.") {
            ZStack {
                DualProgressRings(water: progress, medications: progress, preset: preset,
                                  showMedications: false, centerText: "", lineWidth: 18)
                    .animation(reduceMotion ? nil : .spring(duration: 0.4), value: goal)
                VStack(spacing: 2) {
                    Text("\(Format.liters(goal)) L")
                        .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                        .contentTransition(.numericText(value: goal))
                    Text("≈ \(Int(goal / 250)) glasses")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 210, height: 210)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Daily water goal")
            .accessibilityValue("\(Format.liters(goal)) liters")
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: goal = min(goal + 250, 6000)
                case .decrement: goal = max(goal - 250, 500)
                @unknown default: break
                }
            }
        } content: {
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    ForEach([1500.0, 2000, 2500, 3000], id: \.self) { ml in
                        ChoiceChip(title: String(localized: "\(Format.liters(ml)) L"), isOn: goal == ml, tint: preset.waterEnd) {
                            withAnimation { goal = ml }
                        }
                    }
                }
                Stepper("Fine-tune", value: $goal, in: 500...6000, step: 250)
                    .accessibilityIdentifier("onboarding-goal")
            }
            .sensoryFeedback(.selection, trigger: goal)
        }
    }

    private var medicationStep: some View {
        StepLayout(title: model.medications.isEmpty ? "Add your first medication" : "Your medications",
                   subtitle: "Optional. Nouri only reminds you about what you add yourself.") {
            Image(systemName: model.medications.isEmpty ? "pills.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 96))
                .foregroundStyle(.white, preset.medsGradient)
                .symbolEffect(.bounce, value: model.medications.count)
                .contentTransition(.symbolEffect(.replace))
                .accessibilityHidden(true)
        } content: {
            VStack(spacing: 10) {
                ForEach(model.medications) { med in
                    HStack {
                        Image(systemName: "pills.fill").foregroundStyle(preset.medsStart)
                        Text(med.name).font(.body.weight(.medium))
                        Spacer()
                        Text(med.schedule.times.map(timeText).joined(separator: ", "))
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(.regularMaterial, in: .rect(cornerRadius: 14))
                    .transition(.scale.combined(with: .opacity))
                }
                Button {
                    addMedication = true
                } label: {
                    Label(model.medications.isEmpty ? "Add medication" : "Add another", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
                .tint(preset.medsEnd)
                .accessibilityIdentifier("onboarding-add-med")
            }
            .animation(reduceMotion ? nil : .snappy, value: model.medications.count)
        }
    }

    private var remindersStep: some View {
        StepLayout(title: "Gentle reminders",
                   subtitle: "One permission covers doses and water. Nights stay quiet.") {
            NotificationPreview(preset: preset, reduceMotion: reduceMotion,
                                title: model.medications.first.map { String(localized: "💊 \($0.name)") }
                                    ?? String(localized: "💧 Time for a drink"),
                                bodyText: model.medications.isEmpty
                                    ? String(localized: "A quick sip keeps you on track.")
                                    : String(localized: "Taken · Snooze 10 min · Skip"))
        } content: {
            VStack(spacing: 14) {
                Toggle("Water reminders", isOn: $enableReminders.animation())
                    .tint(preset.waterEnd)
                if enableReminders {
                    HStack(spacing: 8) {
                        ForEach([60, 120, 180], id: \.self) { minutes in
                            ChoiceChip(title: String(localized: "Every \(minutes / 60) h"), isOn: intervalMinutes == minutes, tint: preset.waterEnd) {
                                intervalMinutes = minutes
                            }
                        }
                    }
                    if let next = nextReminder {
                        Label(next, systemImage: "bell.badge")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                }
            }
            .sensoryFeedback(.selection, trigger: intervalMinutes)
        }
    }

    private var healthStep: some View {
        StepLayout(title: "Apple Health",
                   subtitle: "Optionally save the water you log to Health and see what other apps logged.") {
            Image(systemName: model.healthConnected ? "heart.circle.fill" : "heart.circle")
                .font(.system(size: 110))
                .foregroundStyle(.pink)
                .symbolEffect(.bounce, value: model.healthConnected)
                .contentTransition(.symbolEffect(.replace))
                .accessibilityHidden(true)
        } content: {
            if model.healthConnected {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
            } else if model.isHealthAvailable {
                Button {
                    Task { await model.connectHealth() }
                } label: {
                    Text("Connect Apple Health").frame(maxWidth: .infinity).padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
                .tint(.pink)
            } else {
                Text("Apple Health isn't available on this device.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var widgetStep: some View {
        StepLayout(title: "Keep it on your Home Screen",
                   subtitle: "Long-press the Home Screen, tap Edit → Add Widget, then pick Nouri → Today.") {
            WidgetMock(preset: preset, goal: goal, reduceMotion: reduceMotion,
                       medication: model.medications.first)
        } content: {
            Label("On Apple Watch, add the Nouri Hydration and Medications complications to your watch face.",
                  systemImage: "applewatch")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Logic

    private var nextReminder: String? {
        let cal = Calendar.current, now = Date()
        guard let fire = HydrationReminderPlanner.plan(
            enabled: true, intervalMinutes: intervalMinutes,
            quietStartMinutes: model.quietHoursStartMinutes, quietEndMinutes: model.quietHoursEndMinutes,
            todayHydrationML: model.today.hydration.value, goalML: goal,
            now: now, calendar: cal, maxCount: 1,
            lastDrinkAt: model.today.fluids.map(\.timestamp).max()
        ).first?.fireDate else { return nil }
        return cal.isDateInToday(fire)
            ? String(localized: "First nudge today at \(Format.time(fire))")
            : String(localized: "First nudge tomorrow at \(Format.time(fire))")
    }

    private func timeText(_ time: TimeOfDay) -> String {
        Calendar.current.date(bySettingHour: time.hour, minute: time.minute, second: 0, of: .now).map(Format.time) ?? ""
    }

    private func go(to newStep: Int) {
        forward = newStep > step
        withAnimation(reduceMotion ? nil : .spring(duration: 0.45)) { step = newStep }
    }

    private func skip() async {
        // A medication added before skipping still needs permission for its reminders.
        if model.notificationsAllowed == nil, !model.medications.isEmpty {
            await model.requestNotificationPermission()
            await model.rescheduleReminders()
        }
        model.completeOnboarding()
    }

    private func advance() async {
        switch step {
        case 1:
            model.setGoals(hydrationML: goal, calories: model.calorieGoal)
        case 3:
            // Ask here even if water reminders are off: dose reminders need it too.
            if model.notificationsAllowed == nil { await model.requestNotificationPermission() }
            await model.setHydrationReminders(enabled: enableReminders, intervalMinutes: intervalMinutes)
        default:
            break
        }
        if step < lastStep {
            go(to: step + 1)
        } else {
            finished = true
            model.completeOnboarding()
        }
    }
}

// MARK: - Pieces

private struct StepLayout<Hero: View, Content: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    @ViewBuilder let hero: Hero
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                hero
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                VStack(spacing: 8) {
                    Text(title)
                        .font(.title.weight(.bold))
                        .multilineTextAlignment(.center)
                        .accessibilityAddTraits(.isHeader)
                    Text(subtitle)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                content
            }
            .padding(.bottom, 16)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

private struct AnimatedRings<Center: View>: View {
    let preset: AppearancePreset
    let water: Double
    let meds: Double
    let reduceMotion: Bool
    @ViewBuilder let center: Center
    @State private var shown = false

    var body: some View {
        ZStack {
            DualProgressRings(water: GoalProgress(value: shown ? water : 0, goal: 1),
                              medications: GoalProgress(value: shown ? meds : 0, goal: 1),
                              preset: preset, centerText: "", lineWidth: 16)
            center
        }
        .accessibilityHidden(true)
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 1.2).delay(0.2)) { shown = true }
        }
    }
}

private struct AppIconView: View {
    var body: some View {
        Group {
            if let icon = Bundle.main.appIcon {
                Image(uiImage: icon).resizable()
            } else {
                Image(systemName: "drop.fill").resizable().scaledToFit().padding(14).foregroundStyle(.cyan)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
    }
}

private struct FeatureRow: View {
    let symbol: String
    let tint: Color
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 32)
                .accessibilityHidden(true)
            Text(text)
            Spacer(minLength: 0)
        }
    }
}

private struct ChoiceChip: View {
    let title: String
    let isOn: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isOn ? AnyShapeStyle(tint) : AnyShapeStyle(.regularMaterial), in: .capsule)
                .foregroundStyle(isOn ? .white : .primary)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

/// A lock-screen style notification card that slides in.
private struct NotificationPreview: View {
    let preset: AppearancePreset
    let reduceMotion: Bool
    let title: String
    let bodyText: String
    @State private var shown = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AppIconView().scaleEffect(0.55).frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("Nouri").font(.subheadline.weight(.semibold))
                    Spacer()
                    Text("now").font(.caption).foregroundStyle(.secondary)
                }
                Text(title).font(.subheadline.weight(.semibold))
                Text(bodyText).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.regularMaterial, in: .rect(cornerRadius: 22))
        .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        .offset(y: shown ? 0 : -40)
        .opacity(shown ? 1 : 0)
        .padding(.vertical, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Example notification: \(title)")
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(duration: 0.6).delay(0.25)) { shown = true }
        }
    }
}

/// What the medium Today widget looks like, with sample numbers.
private struct WidgetMock: View {
    let preset: AppearancePreset
    let goal: Double
    let reduceMotion: Bool
    let medication: MedicationInfo?
    @State private var shown = false

    var body: some View {
        let evening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
        HStack(alignment: .top, spacing: 16) {
            column(title: "Water", symbol: "drop.fill", tint: preset.waterEnd,
                   value: String(localized: "\(Format.liters(goal * 0.64)) L"),
                   caption: String(localized: "of \(Format.liters(goal)) L · 64%"), fraction: 0.64)
            column(title: "Medications", symbol: "pills.fill", tint: preset.medsEnd,
                   value: "1/2",
                   caption: String(localized: "Next \(Format.time(evening)) \(medication?.name ?? String(localized: "Vitamin D"))"),
                   fraction: 0.5)
        }
        .padding(16)
        .frame(maxWidth: 340)
        .background(.regularMaterial, in: .rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 14, y: 8)
        .rotation3DEffect(.degrees(shown ? 0 : 12), axis: (x: 1, y: 0, z: 0))
        .padding(.vertical, 16)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Example Today widget")
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(duration: 0.9).delay(0.2)) { shown = true }
        }
    }

    private func column(title: LocalizedStringKey, symbol: String, tint: Color, value: String,
                        caption: String, fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .lineLimit(1)
            Text(value).font(.title2.bold().monospacedDigit())
            Text(caption).font(.caption).foregroundStyle(.secondary).lineLimit(1).minimumScaleFactor(0.7)
            ProgressView(value: shown ? fraction : 0).tint(tint).padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private extension Bundle {
    var appIcon: UIImage? {
        guard let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let files = primary["CFBundleIconFiles"] as? [String],
              let name = files.last else { return nil }
        return UIImage(named: name)
    }
}
