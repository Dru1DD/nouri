import Foundation
@testable import NouriKit

func calendar(_ tz: String = "Europe/Kyiv") -> Calendar {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: tz)!
    return cal
}

func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int = 0, _ mi: Int = 0, in cal: Calendar = calendar()) -> Date {
    cal.date(from: DateComponents(year: y, month: mo, day: d, hour: h, minute: mi))!
}

func med(_ name: String, _ times: [(Int, Int)], weekdays: Set<Int> = [], start: Date? = nil, end: Date? = nil) -> MedicationInfo {
    MedicationInfo(name: name, dosage: 1, unit: "tablet",
                   schedule: MedicationSchedule(times: times.map { TimeOfDay(hour: $0.0, minute: $0.1) },
                                                weekdays: weekdays, startDate: start, endDate: end))
}

/// Mutable clock for deterministic tests.
@MainActor
final class TestClock {
    var now: Date
    init(_ now: Date) { self.now = now }
    func advance(minutes: Double) { now = now.addingTimeInterval(minutes * 60) }
}

@MainActor
func makeStore() -> NouriStore {
    NouriStore(container: try! NouriStore.makeContainer(inMemory: true))
}

/// In-process transport pair. `isOnline = false` simulates an unreachable counterpart:
/// messages queue up (like `transferUserInfo`) until `flush()`.
@MainActor
final class LoopbackTransport: SyncTransport {
    var onReceive: (@MainActor (SyncMessage) -> Void)?
    var onFirstActivation: (@MainActor () -> Void)?
    weak var peer: LoopbackTransport?
    var isOnline = true
    private(set) var outbox: [SyncMessage] = []

    static func pair() -> (LoopbackTransport, LoopbackTransport) {
        let a = LoopbackTransport(), b = LoopbackTransport()
        a.peer = b
        b.peer = a
        return (a, b)
    }

    func send(_ message: SyncMessage) {
        outbox.append(message)
        if isOnline { flush() }
    }

    func flush() {
        let queued = outbox
        outbox.removeAll()
        queued.forEach { peer?.onReceive?($0) }
    }
}
