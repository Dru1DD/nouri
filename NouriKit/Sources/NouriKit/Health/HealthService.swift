import Foundation

/// Totals recorded in Apple Health by *other* apps. Shown separately, never merged
/// into Nouri's own entries.
public struct ImportedTotals: Hashable, Sendable {
    public var waterML: Double
    public var kcal: Double

    public init(waterML: Double, kcal: Double) {
        self.waterML = waterML
        self.kcal = kcal
    }
}

public protocol HealthService: Sendable {
    func requestAuthorization() async
    /// Mirrors an app entry into Health. Idempotent (sync identifiers).
    func export(_ record: SyncRecord) async
    func importedTotals(in interval: DateInterval) async -> ImportedTotals?
}

#if os(iOS)
import HealthKit

public final class HealthKitService: HealthService {
    private let store = HKHealthStore()
    private let water = HKQuantityType(.dietaryWater)
    private let energy = HKQuantityType(.dietaryEnergyConsumed)

    public init?() {
        guard HKHealthStore.isHealthDataAvailable() else { return nil }
    }

    public func requestAuthorization() async {
        let types: Set = [water, energy]
        try? await store.requestAuthorization(toShare: types, read: types)
    }

    public func export(_ record: SyncRecord) async {
        switch record {
        case .fluid(let r):
            let kcal = r.calories > 0 && r.deletedAt == nil ? r.calories : 0
            await write(type: water, unit: .literUnit(with: .milli), value: r.amountML, date: r.timestamp,
                        syncID: "fluid-\(r.id)", version: r.updatedAt, deleted: r.deletedAt != nil)
            await write(type: energy, unit: .kilocalorie(), value: kcal, date: r.timestamp,
                        syncID: "fluid-kcal-\(r.id)", version: r.updatedAt, deleted: kcal == 0)
        case .food(let r):
            await write(type: energy, unit: .kilocalorie(), value: r.calories, date: r.timestamp,
                        syncID: "food-\(r.id)", version: r.updatedAt, deleted: r.deletedAt != nil)
        case .dose:
            break
        }
    }

    public func importedTotals(in interval: DateInterval) async -> ImportedTotals? {
        async let ml = sum(water, unit: .literUnit(with: .milli), interval: interval)
        async let kcal = sum(energy, unit: .kilocalorie(), interval: interval)
        let (m, k) = await (ml, kcal)
        guard m != nil || k != nil else { return nil }
        return ImportedTotals(waterML: m ?? 0, kcal: k ?? 0)
    }

    /// HealthKit replaces a sample with the same sync identifier when the version is higher,
    /// so re-exporting the same record never duplicates it.
    private func write(type: HKQuantityType, unit: HKUnit, value: Double, date: Date,
                       syncID: String, version: Date, deleted: Bool) async {
        guard store.authorizationStatus(for: type) == .sharingAuthorized else { return }
        if deleted {
            let predicate = HKQuery.predicateForObjects(withMetadataKey: HKMetadataKeySyncIdentifier, allowedValues: [syncID])
            _ = try? await store.deleteObjects(of: type, predicate: predicate)
            return
        }
        let sample = HKQuantitySample(
            type: type, quantity: HKQuantity(unit: unit, doubleValue: value), start: date, end: date,
            metadata: [HKMetadataKeySyncIdentifier: syncID,
                       HKMetadataKeySyncVersion: Int(version.timeIntervalSince1970 * 1000)]
        )
        try? await store.save(sample)
    }

    private func sum(_ type: HKQuantityType, unit: HKUnit, interval: DateInterval) async -> Double? {
        let ours = HKQuery.predicateForObjects(from: HKSource.default())
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            HKQuery.predicateForSamples(withStart: interval.start, end: interval.end, options: .strictStartDate),
            NSCompoundPredicate(notPredicateWithSubpredicate: ours),
        ])
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: type, predicate: predicate), options: .cumulativeSum)
        return try? await descriptor.result(for: store)?.sumQuantity()?.doubleValue(for: unit)
    }
}
#endif
