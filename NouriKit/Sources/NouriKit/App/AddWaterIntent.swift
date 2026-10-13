#if os(iOS)
import AppIntents

/// Lets the app and widget extension pick up intents defined in this package.
public struct NouriKitIntents: AppIntentsPackage {}

/// Interactive widget / Shortcuts quick-add for water.
///
/// A `LiveActivityIntent` runs in the app's process (launched in the background if needed), not in
/// the widget extension, so the entry goes through `AppModel` like any other: synced to the Watch,
/// mirrored to Health, widgets reloaded. The app registers its `AppModel` as a dependency at launch.
public struct AddWaterIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Add Water"
    public static let description = IntentDescription("Log a glass of water in Nouri.")
    public static var isDiscoverable: Bool { true }

    @Parameter(title: "Amount (ml)", default: 250)
    public var amountML: Int

    @Dependency private var model: AppModel

    public init() {
        self.amountML = 250
    }

    public init(amountML: Int) {
        self.amountML = amountML
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        let ml = amountML > 0 ? amountML : 250
        model.addFluid(Double(ml))
        return .result()
    }
}
#endif
