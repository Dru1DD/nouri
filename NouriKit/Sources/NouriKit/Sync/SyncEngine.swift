import Foundation

/// Moves `SyncMessage`s to the paired device. Implementations must deliver records
/// at-least-once; the engine tolerates duplicates.
@MainActor
public protocol SyncTransport: AnyObject {
    var onReceive: (@MainActor (SyncMessage) -> Void)? { get set }
    /// Called when the transport becomes ready for the first time on this install.
    var onFirstActivation: (@MainActor () -> Void)? { get set }
    func send(_ message: SyncMessage)
}

@MainActor
public final class SyncEngine {
    /// How much history a fresh counterpart receives.
    public static let backfillWindow: TimeInterval = 3 * 86_400

    private let store: NouriStore
    private let transport: SyncTransport
    private let now: () -> Date
    /// Called after remote data changed the store.
    public var onRemoteChange: ((_ records: [SyncRecord]) -> Void)?

    public init(store: NouriStore, transport: SyncTransport, now: @escaping () -> Date = Date.init) {
        self.store = store
        self.transport = transport
        self.now = now
        transport.onReceive = { [weak self] in self?.receive($0) }
    }

    public func publish(_ record: SyncRecord) {
        transport.send(.record(record))
    }

    public func publishSettings() {
        transport.send(.snapshot(store.snapshot()))
    }

    public func requestBackfill() {
        transport.send(.backfillRequest)
    }

    func receive(_ message: SyncMessage) {
        switch message {
        case .record(let record):
            if store.apply(record) { onRemoteChange?([record]) }
        case .snapshot(let snapshot):
            if store.apply(snapshot) { onRemoteChange?([]) }
        case .backfillRequest:
            for record in store.records(updatedSince: now().addingTimeInterval(-Self.backfillWindow)) {
                transport.send(.record(record))
            }
            publishSettings()
        }
    }
}

#if canImport(WatchConnectivity)
@preconcurrency import WatchConnectivity

/// WatchConnectivity transport.
/// - Records and backfill requests use `transferUserInfo`: queued by the OS, survives app
///   termination and delivers in order once the counterpart is reachable.
/// - Settings use `updateApplicationContext`: only the latest snapshot matters.
@MainActor
public final class WatchConnectivityTransport: NSObject, SyncTransport {
    public var onReceive: (@MainActor (SyncMessage) -> Void)?
    public var onFirstActivation: (@MainActor () -> Void)?

    private let session: WCSession
    private var outbox: [SyncMessage] = []  // held only until activation completes
    private nonisolated static let key = "m"
    private static let activatedFlag = "nouri.wc.activatedOnce"

    public init(session: WCSession = .default) {
        self.session = session
        super.init()
    }

    public func activate() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }

    public func send(_ message: SyncMessage) {
        guard session.activationState == .activated else {
            outbox.append(message)
            return
        }
        #if os(iOS)
        guard session.isPaired, session.isWatchAppInstalled else { return }
        #endif
        guard let data = try? JSONEncoder().encode(message) else { return }
        if case .snapshot = message {
            try? session.updateApplicationContext([Self.key: data])
        } else {
            session.transferUserInfo([Self.key: data])
        }
    }

    private func didActivate() {
        let queued = outbox
        outbox.removeAll()
        queued.forEach(send)
        if !UserDefaults.standard.bool(forKey: Self.activatedFlag) {
            UserDefaults.standard.set(true, forKey: Self.activatedFlag)
            onFirstActivation?()
        }
        if let data = session.receivedApplicationContext[Self.key] as? Data { deliver(data) }
    }

    private func deliver(_ data: Data) {
        guard let message = try? JSONDecoder().decode(SyncMessage.self, from: data) else { return }
        onReceive?(message)
    }
}

extension WatchConnectivityTransport: WCSessionDelegate {
    nonisolated public func session(_ session: WCSession, activationDidCompleteWith state: WCSessionActivationState, error: Error?) {
        guard state == .activated else { return }
        Task { @MainActor in self.didActivate() }
    }

    nonisolated public func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        guard let data = userInfo[Self.key] as? Data else { return }
        Task { @MainActor in self.deliver(data) }
    }

    nonisolated public func session(_ session: WCSession, didReceiveApplicationContext context: [String: Any]) {
        guard let data = context[Self.key] as? Data else { return }
        Task { @MainActor in self.deliver(data) }
    }

    #if os(iOS)
    nonisolated public func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()  // switching between multiple watches
    }

    nonisolated public func sessionWatchStateDidChange(_ session: WCSession) {
        guard session.isWatchAppInstalled else { return }
        // A (re)installed watch app asks for backfill itself; push settings right away.
        Task { @MainActor in self.onFirstActivation?() }
    }
    #endif
}
#endif
