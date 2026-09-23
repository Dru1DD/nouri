#if os(iOS)
import AppIntents

/// Lets the app and widget extension pick up intents defined in this package.
public struct NouriKitIntents: AppIntentsPackage {}

/// The "+250 ml" button on the Home Screen widget.
///
/// A `LiveActivityIntent` runs in the app's process (launched in the background if needed), not in
/// the widget extension, so the entry goes through `AppModel` like any other: synced to the Watch,
/// mirrored to Health, widgets reloaded. The app registers its `AppModel` as a dependency at launch.
public struct AddWaterIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Add Water"
    public static let isDiscoverable = false

    @Parameter(title: "Amount (ml)")
    public var amountML: Int

    @Dependency private var model: AppModel

    public init() {}

    public init(amountML: Int) {
        self.amountML = amountML
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        model.addFluid(Double(amountML))
        return .result()
    }
}
#endif
