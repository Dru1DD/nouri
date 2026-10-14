#if canImport(SwiftUI)
import SwiftUI

/// Activity-style concentric rings. Outer = water (the main goal), inner = medications.
public struct DualProgressRings: View {
    public var water: GoalProgress
    public var medications: GoalProgress
    public var preset: AppearancePreset
    public var showMedications: Bool
    public var centerText: String
    public var lineWidth: CGFloat

    public init(water: GoalProgress, medications: GoalProgress, preset: AppearancePreset,
                showMedications: Bool = true, centerText: String, lineWidth: CGFloat = 8) {
        self.water = water
        self.medications = medications
        self.preset = preset
        self.showMedications = showMedications
        self.centerText = centerText
        self.lineWidth = lineWidth
    }

    public var body: some View {
        ZStack {
            ring(fraction: water.fraction, gradient: preset.waterGradient, inset: 0)
            if showMedications {
                ring(fraction: medications.fraction, gradient: preset.medsGradient, inset: lineWidth + 3)
            }
            Text(centerText)
                .font(.system(.caption, design: .rounded, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today")
        .accessibilityValue(valueText)
    }

    private var valueText: String {
        if showMedications {
            String(localized: "Water \(water.percent) percent, medications \(medications.percent) percent", bundle: .module)
        } else {
            String(localized: "Water \(water.percent) percent", bundle: .module)
        }
    }

    private func ring(fraction: Double, gradient: LinearGradient, inset: CGFloat) -> some View {
        ZStack {
            Circle()
                .stroke(Color.primary.opacity(0.12), lineWidth: lineWidth)
                .padding(inset)
            Circle()
                .trim(from: 0, to: min(max(fraction, 0), 1))
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(inset)
        }
    }
}

public struct SingleProgressRing: View {
    public var progress: GoalProgress
    public var gradient: LinearGradient
    public var centerText: String
    public var accessibilityName: String

    public init(progress: GoalProgress, gradient: LinearGradient, centerText: String, accessibilityName: String) {
        self.progress = progress
        self.gradient = gradient
        self.centerText = centerText
        self.accessibilityName = accessibilityName
    }

    public var body: some View {
        ZStack {
            Circle().stroke(Color.primary.opacity(0.12), lineWidth: 8)
            Circle()
                .trim(from: 0, to: progress.fraction)
                .stroke(gradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(centerText)
                .font(.system(.caption, design: .rounded, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityName)
        .accessibilityValue("\(progress.percent) percent")
    }
}
#endif
