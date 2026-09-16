import BackgroundTasks
import NouriKit
import SwiftData
import SwiftUI
import UserNotifications

@main
struct NouriApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(delegate.model)
                .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in timeChanged() }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in timeChanged() }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            timeChanged()
            Task { await delegate.model.refreshExternal() }
            AppDelegate.scheduleBackgroundRefresh()
        }
        .backgroundTask(.appRefresh(AppDelegate.refreshTaskID)) {
            // Keeps the rolling reminder window topped up if the app isn't opened for a while.
            await AppDelegate.scheduleBackgroundRefresh()
            await delegate.model.rescheduleReminders()
        }
    }

    private func timeChanged() {
        delegate.model.refresh()
        Task { await delegate.model.rescheduleReminders() }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static let refreshTaskID = "com.dru1dd.nouri.reminders"
    static let isUITesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")

    let model: AppModel

    override init() {
        model = Self.makeModel()
        super.init()
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Must be set before launch finishes to receive actions that launched the app in the background.
        UNUserNotificationCenter.current().delegate = self
        DoseNotification.registerCategory()
        return true
    }

    // Completion-handler variants, not `async`: UIKit requires the completion handler to run on
    // the main thread, and a nonisolated async implementation finishes on a background executor
    // ("Call must be made on main thread" crash when opening a notification).
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

    static func scheduleBackgroundRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 12 * 3600)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func makeModel() -> AppModel {
        let container: ModelContainer
        do {
            container = try NouriStore.makeContainer(inMemory: isUITesting)
        } catch {
            // No usable store means nothing we log would persist; failing loudly beats silent data loss.
            fatalError("Unable to open the Nouri database: \(error)")
        }
        if isUITesting {
            return AppModel(store: NouriStore(container: container),
                            reminders: ReminderScheduler(client: InMemoryNotificationClient()))
        }
        let transport = WatchConnectivityTransport()
        let model = AppModel(
            store: NouriStore(container: container),
            transport: transport,
            health: HealthKitService(),
            reminders: ReminderScheduler(client: SystemNotificationClient())
        )
        transport.activate()  // after AppModel wired its handlers
        return model
    }
}
