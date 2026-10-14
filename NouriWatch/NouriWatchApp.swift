import NouriKit
import SwiftData
import SwiftUI
import UserNotifications
import WatchConnectivity
import WatchKit

@main
struct NouriWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(delegate.model)
                .tint(delegate.model.appearancePreset.accent)
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
                    delegate.model.refresh()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            delegate.model.refresh()
            delegate.model.syncWithCounterpart()
            Task { await delegate.model.rescheduleReminders() }
        }
        // A complication transfer from the iPhone wakes the app in the background; stay alive
        // until WatchConnectivity has handed over the data, so the store and complications update.
        .backgroundTask(.watchConnectivity) {
            while WCSession.default.hasContentPending {
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }
}

/// The Watch keeps its own store and plans the same local reminders as iPhone. iPhone mirroring
/// of phone-scheduled alerts is unreliable for an independent Watch app, so the Watch schedules
/// its own. Taken/Skip/Snooze on either device still sync through WatchConnectivity.
final class WatchAppDelegate: NSObject, WKApplicationDelegate, UNUserNotificationCenterDelegate {
    let model: AppModel

    override init() {
        let container: ModelContainer
        do {
            container = try NouriStore.makeContainer()
        } catch {
            fatalError("Unable to open the Nouri database: \(error)")
        }
        let transport = WatchConnectivityTransport()
        model = AppModel(store: NouriStore(container: container), transport: transport,
                         reminders: ReminderScheduler(client: SystemNotificationClient()))
        transport.activate()
        super.init()
    }

    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
        DoseNotification.registerCategories()
        Task { @MainActor in
            await model.requestNotificationPermission()
            await model.rescheduleReminders()
        }
    }

    // Completion-handler variants: the handler must be called on the main thread.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping @Sendable () -> Void) {
        let action = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        let hydrateML = HydrationNotification.amountML(for: action)
        let dosePayload = DoseNotification.payload(from: userInfo)
        Task { @MainActor in
            if let hydrateML {
                model.addFluid(hydrateML)
            } else if let dosePayload {
                await model.handleNotificationAction(action, payload: dosePayload)
            }
            completionHandler()
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping @Sendable (UNNotificationPresentationOptions) -> Void) {
        DispatchQueue.main.async { completionHandler([.banner, .list, .sound]) }
    }
}
