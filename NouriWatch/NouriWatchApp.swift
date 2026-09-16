import NouriKit
import SwiftData
import SwiftUI
import WatchKit

@main
struct NouriWatchApp: App {
    @State private var model = Self.makeModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(model)
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in model.refresh() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { model.refresh() }
        }
    }

    /// The Watch keeps its own store and exchanges events with the iPhone. It schedules no
    /// notifications of its own: iPhone reminders are mirrored to the Watch by the system,
    /// and their actions are handled by the iPhone app, so nothing fires twice.
    private static func makeModel() -> AppModel {
        let container: ModelContainer
        do {
            container = try NouriStore.makeContainer()
        } catch {
            fatalError("Unable to open the Nouri database: \(error)")
        }
        let transport = WatchConnectivityTransport()
        let model = AppModel(store: NouriStore(container: container), transport: transport)
        transport.activate()
        return model
    }
}
