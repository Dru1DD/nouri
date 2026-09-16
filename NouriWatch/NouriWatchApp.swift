import NouriKit
import SwiftData
import SwiftUI
import UserNotifications
import WatchKit

@main
struct NouriWatchApp: App {
    @WKApplicationDelegateAdaptor(WatchAppDelegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(delegate.model)
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in
                    delegate.model.refresh()
                }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            delegate.model.refresh()
            // Snoozing from the Watch schedules a local notification, which needs permission here.
            if delegate.model.notificationsAllowed == nil, !delegate.model.medications.isEmpty {
                Task { await delegate.model.requestNotificationPermission() }
            }
        }
    }
}

/// The Watch keeps its own store and exchanges events with the iPhone. It doesn't plan dose
/// reminders: iPhone reminders are mirrored to the Watch by the system. Actions tapped on the
/// Watch may be delivered here, so they are handled the same way as on the iPhone.
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
                         reminders: ReminderScheduler(client: SystemNotificationClient()), plansReminders: false)
        transport.activate()
        super.init()
    }

    func applicationDidFinishLaunching() {
        UNUserNotificationCenter.current().delegate = self
        DoseNotification.registerCategory()
    }

    // Completion-handler variants: the handler must be called on the main thread.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse,
                                            withCompletionHandler completionHandler: @escaping @Sendable () -> Void) {
        let action = response.actionIdentifier
        let payload = DoseNotification.payload(from: response.notification.request.content.userInfo)
        Task { @MainActor in
            if let payload { await model.handleNotificationAction(action, payload: payload) }
            completionHandler()
        }
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification,
                                            withCompletionHandler completionHandler: @escaping @Sendable (UNNotificationPresentationOptions) -> Void) {
        DispatchQueue.main.async { completionHandler([.banner, .list, .sound]) }
    }
}
