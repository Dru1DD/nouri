import Foundation

/// Local, privacy-first usage counters: `[day since install: [event: count]]`.
/// No timestamps, amounts or names. Nothing leaves the device unless the user shares the JSON.
public final class AnalyticsStore: @unchecked Sendable {
    // ponytail: NSLock covers one process only; the app and the widget extension can race on the
    // read-modify-write and drop a count. Fine for beta stats; use NSFileCoordinator if counts must be exact.
    private let defaults: UserDefaults
    private let lock = NSLock()
    private let key = "nouri.analytics.counters"

    public init(suiteName: String = NouriStore.appGroup) {
        defaults = UserDefaults(suiteName: suiteName) ?? .standard
    }

    public func trackFirstOpenIfNeeded() {
        guard !defaults.bool(forKey: "nouri.analytics.first_open_done") else { return }
        defaults.set(true, forKey: "nouri.analytics.first_open_done")
        track("first_open")
    }

    public func track(_ name: String, _ params: [String: String] = [:]) {
        update(name, params) { $0 += 1 }
    }

    /// Counts at most once per day (e.g. a widget family being rendered).
    public func trackOncePerDay(_ name: String, _ params: [String: String] = [:]) {
        update(name, params) { $0 = max($0, 1) }
    }

    public func exportJSON() throws -> Data {
        lock.lock()
        defer { lock.unlock() }
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(Export(appVersion: version, days: load()))
    }

    private func update(_ name: String, _ params: [String: String], _ change: (inout Int) -> Void) {
        let event = ([name] + params.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }).joined(separator: "|")
        lock.lock()
        defer { lock.unlock() }
        var days = load()
        change(&days[String(dayIndex()), default: [:]][event, default: 0])
        defaults.set(try? JSONEncoder().encode(days), forKey: key)
    }

    private func dayIndex() -> Int {
        let install = defaults.object(forKey: "nouri.analytics.install") as? Date ?? {
            let now = Date()
            defaults.set(now, forKey: "nouri.analytics.install")
            return now
        }()
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: install), to: cal.startOfDay(for: Date())).day ?? 0
    }

    private func load() -> [String: [String: Int]] {
        guard let data = defaults.data(forKey: key) else { return [:] }
        return (try? JSONDecoder().decode([String: [String: Int]].self, from: data)) ?? [:]
    }

    struct Export: Codable {
        var appVersion: String
        var days: [String: [String: Int]]
    }
}
