import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(UIKit)
import UIKit
#endif

public enum AppearancePreset: String, Codable, CaseIterable, Identifiable, Sendable {
    case `default`, ocean, midnight, highContrast

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .default: String(localized: "Default", bundle: .module)
        case .ocean: String(localized: "Ocean", bundle: .module)
        case .midnight: String(localized: "Midnight", bundle: .module)
        case .highContrast: String(localized: "High Contrast", bundle: .module)
        }
    }

    /// sRGB components 0…1: (r, g, b) for water start, water end, meds start, meds end.
    /// Each ring stays in one hue (light → deep); water and meds use opposite hues so the
    /// rings never blend, also for red-green color blindness (blue vs orange/pink/yellow).
    public var palette: (water: (Double, Double, Double), waterEnd: (Double, Double, Double),
                         meds: (Double, Double, Double), medsEnd: (Double, Double, Double)) {
        switch self {
        case .default:
            ((0.30, 0.68, 1.00), (0.04, 0.45, 0.95), (1.00, 0.66, 0.25), (1.00, 0.45, 0.10))
        case .ocean:
            ((0.25, 0.85, 0.95), (0.00, 0.60, 0.85), (1.00, 0.50, 0.50), (0.92, 0.30, 0.38))
        case .midnight:
            ((0.55, 0.55, 1.00), (0.36, 0.33, 0.95), (1.00, 0.45, 0.75), (0.88, 0.22, 0.58))
        case .highContrast:
            ((0.20, 0.75, 1.00), (0.00, 0.55, 1.00), (1.00, 0.88, 0.10), (1.00, 0.75, 0.00))
        }
    }

    #if canImport(SwiftUI)
    public var waterStart: Color { Color(red: palette.water.0, green: palette.water.1, blue: palette.water.2) }
    public var waterEnd: Color { Color(red: palette.waterEnd.0, green: palette.waterEnd.1, blue: palette.waterEnd.2) }
    public var medsStart: Color { Color(red: palette.meds.0, green: palette.meds.1, blue: palette.meds.2) }
    public var medsEnd: Color { Color(red: palette.medsEnd.0, green: palette.medsEnd.1, blue: palette.medsEnd.2) }
    public var waterGradient: LinearGradient {
        LinearGradient(colors: [waterStart, waterEnd], startPoint: .top, endPoint: .bottom)
    }
    public var medsGradient: LinearGradient {
        LinearGradient(colors: [medsStart, medsEnd], startPoint: .top, endPoint: .bottom)
    }
    /// App-wide accent: buttons, toggles, links.
    public var accent: Color { waterEnd }

    /// Midnight is a dark theme; the others follow the system setting.
    public var colorScheme: ColorScheme? { self == .midnight ? .dark : nil }

    /// Screen background behind lists and cards. Nil keeps the system background.
    public var background: Color? {
        switch self {
        case .default: nil
        case .ocean: Self.dynamic(light: (0.89, 0.95, 0.98), dark: (0.02, 0.11, 0.15))
        case .midnight: Color(red: 0.06, green: 0.06, blue: 0.16)
        case .highContrast: Self.dynamic(light: (0.84, 0.84, 0.87), dark: (0, 0, 0))  // grey so white cards stand out
        }
    }

    /// Primary text; `.secondary` derives from it. Nil keeps the system label color.
    public var text: Color? {
        switch self {
        case .default: nil
        case .ocean: Self.dynamic(light: (0.04, 0.20, 0.30), dark: (0.84, 0.95, 1.00))
        case .midnight: Color(red: 0.90, green: 0.90, blue: 1.00)
        case .highContrast: Self.dynamic(light: (0, 0, 0), dark: (1, 1, 1))
        }
    }

    private static func dynamic(light: (Double, Double, Double), dark: (Double, Double, Double)) -> Color {
        #if canImport(UIKit) && !os(watchOS)
        Color(uiColor: UIColor { traits in
            let c = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: c.0, green: c.1, blue: c.2, alpha: 1)
        })
        #else
        Color(red: dark.0, green: dark.1, blue: dark.2)  // watchOS is always dark
        #endif
    }
    /// Soft wash for widget and screen backgrounds, layered over the system background.
    public var backgroundWash: LinearGradient {
        LinearGradient(colors: [waterStart.opacity(0.22), medsStart.opacity(0.10)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    #endif
}

public enum LogSurface: String, Codable, Sendable {
    case phone, watch, shortcut, notification
}
