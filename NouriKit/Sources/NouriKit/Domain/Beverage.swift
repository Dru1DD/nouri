import Foundation

public enum BeverageType: String, Codable, CaseIterable, Identifiable, Sendable {
    case water, coffee, tea, milk, juice, softDrink, energyDrink, beer, wine, spirits, other

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .water: String(localized: "Water", bundle: .module)
        case .coffee: String(localized: "Coffee", bundle: .module)
        case .tea: String(localized: "Tea", bundle: .module)
        case .milk: String(localized: "Milk", bundle: .module)
        case .juice: String(localized: "Juice", bundle: .module)
        case .softDrink: String(localized: "Soft drink", bundle: .module)
        case .energyDrink: String(localized: "Energy drink", bundle: .module)
        case .beer: String(localized: "Beer", bundle: .module)
        case .wine: String(localized: "Wine", bundle: .module)
        case .spirits: String(localized: "Spirits", bundle: .module)
        case .other: String(localized: "Other", bundle: .module)
        }
    }

    public var symbol: String {
        switch self {
        case .water: "drop.fill"
        case .coffee: "cup.and.saucer.fill"
        case .tea: "cup.and.heat.waves.fill"
        case .milk: "waterbottle.fill"
        case .juice: "carrot.fill"
        case .softDrink: "takeoutbag.and.cup.and.straw.fill"
        case .energyDrink: "bolt.fill"
        case .beer: "mug.fill"
        case .wine: "wineglass.fill"
        case .spirits: "flask.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    /// Alcohol is logged (and its calories counted) but doesn't count toward the water goal.
    public var countsTowardHydration: Bool {
        switch self {
        case .beer, .wine, .spirits: false
        default: true
        }
    }

    /// A typical single serving, the starting amount when picking a drink on the Watch.
    public var defaultServingML: Double {
        switch self {
        case .coffee: 200
        case .softDrink: 330
        case .beer: 500
        case .wine: 150
        case .spirits: 50
        default: 250
        }
    }

    /// Rough typical energy density, used only to prefill the calories field.
    /// The user can always override it per entry.
    public var defaultKcalPer100ML: Double {
        switch self {
        case .water, .other: 0
        case .coffee, .tea: 1      // black, unsweetened
        case .milk: 50             // 2.5% fat
        case .juice: 45            // orange
        case .softDrink: 42        // regular cola
        case .energyDrink: 45
        case .beer: 43             // lager, ~5%
        case .wine: 83             // dry, ~12%
        case .spirits: 231         // 40% ABV
        }
    }

    public func defaultCalories(amountML: Double) -> Double {
        (amountML * defaultKcalPer100ML / 100).rounded()
    }
}
