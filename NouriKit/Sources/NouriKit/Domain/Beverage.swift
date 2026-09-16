import Foundation

public enum BeverageType: String, Codable, CaseIterable, Identifiable, Sendable {
    case water, coffee, tea, softDrink, other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .water: String(localized: "Water", bundle: .module)
        case .coffee: String(localized: "Coffee", bundle: .module)
        case .tea: String(localized: "Tea", bundle: .module)
        case .softDrink: String(localized: "Soft drink", bundle: .module)
        case .other: String(localized: "Other", bundle: .module)
        }
    }

    public var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .coffee: "cup.and.saucer.fill"
        case .tea: "mug.fill"
        case .softDrink: "takeoutbag.and.cup.and.straw.fill"
        case .other: "waterbottle.fill"
        }
    }

    /// Rough default energy density, used only to prefill the calories field.
    /// The user can always override it per entry.
    public var defaultKcalPer100ML: Double {
        switch self {
        case .water, .other: 0
        case .coffee, .tea: 1
        case .softDrink: 42
        }
    }

    public func defaultCalories(amountML: Double) -> Double {
        (amountML * defaultKcalPer100ML / 100).rounded()
    }
}
