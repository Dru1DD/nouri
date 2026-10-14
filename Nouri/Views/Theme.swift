import NouriKit
import SwiftUI

extension View {
    /// Accent, text color and color scheme for a whole presentation (root, sheets, covers).
    func themedRoot(_ preset: AppearancePreset) -> some View {
        tint(preset.accent)
            .foregroundStyle(preset.text.map(AnyShapeStyle.init) ?? AnyShapeStyle(.primary))
            .preferredColorScheme(preset.colorScheme)
    }

    /// Palette background behind a List, Form or plain screen.
    func themedBackground(_ preset: AppearancePreset) -> some View {
        scrollContentBackground(preset.background == nil ? .automatic : .hidden)
            .background {
                if let background = preset.background { background.ignoresSafeArea() }
            }
    }
}
