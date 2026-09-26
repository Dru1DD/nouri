import NouriKit
import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var step = 0
    @State private var goal: Double = 2500
    @State private var enableReminders = true

    var body: some View {
        NavigationStack {
            TabView(selection: $step) {
                goalPage.tag(0)
                remindersPage.tag(1)
                healthPage.tag(2)
                widgetPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .navigationTitle("Welcome to Nouri")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button(step < 3 ? "Continue" : "Get Started") {
                    Task { await advance() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
                .padding()
                .accessibilityIdentifier("onboarding-continue")
            }
        }
    }

    private var goalPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "drop.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)
            Text("Set your daily water goal")
                .font(.title2.weight(.semibold))
            Text("Nouri helps you drink enough water. You can change this anytime in Settings.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Stepper(value: $goal, in: 1000...5000, step: 250) {
                Text("\(Format.liters(goal)) L")
                    .font(.title.monospacedDigit())
            }
            .padding(.top)
        }
        .padding()
    }

    private var remindersPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)
            Text("Hydration reminders")
                .font(.title2.weight(.semibold))
            Text("Get gentle nudges during the day. Quiet hours keep evenings and nights free.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Toggle("Enable reminders", isOn: $enableReminders)
                .padding(.top)
        }
        .padding()
    }

    private var healthPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(.pink)
                .accessibilityHidden(true)
            Text("Apple Health")
                .font(.title2.weight(.semibold))
            Text("Optionally connect Apple Health so water and calories stay in sync. You can skip this.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            if model.isHealthAvailable {
                Button("Connect Apple Health") {
                    Task { await model.connectHealth() }
                }
                .buttonStyle(.bordered)
                .disabled(model.healthConnected)
            }
            if model.healthConnected {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }

    private var widgetPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "widget.small")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)
            Text("Add a Home Screen widget")
                .font(.title2.weight(.semibold))
            Text("Long-press your Home Screen, tap Edit, then add the Nouri Hydration widget for one-tap logging.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private func advance() async {
        if step == 0 {
            model.setGoals(hydrationML: goal, calories: model.calorieGoal)
        }
        if step == 1 {
            await model.setHydrationReminders(enabled: enableReminders)
        }
        if step < 3 {
            step += 1
        } else {
            model.completeOnboarding()
        }
    }
}
