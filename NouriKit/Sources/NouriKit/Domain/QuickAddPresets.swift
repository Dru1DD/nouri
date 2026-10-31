import Foundation

/// Hydration quick-add amounts in ml, in display order. Edited on iPhone, mirrored to the Watch.
/// At least one and at most `maxCount`: four fit one iPhone row next to "…", and the Watch
/// shows the first three in its corners with the rest below the fold.
public enum QuickAddPresets {
    public static let defaults = [100, 250, 500]
    /// Same bounds as the Watch's Digital Crown custom amount.
    public static let range = 10...2000
    public static let maxCount = 4

    public enum Problem: Error, Equatable, Sendable {
        case outOfRange, duplicate, full
    }

    /// Why `amount` can't go into `amounts` (at `index` when editing, appended otherwise).
    public static func problem(adding amount: Int, to amounts: [Int], at index: Int? = nil) -> Problem? {
        guard range.contains(amount) else { return .outOfRange }
        if amounts.enumerated().contains(where: { $0.offset != index && $0.element == amount }) { return .duplicate }
        if index == nil, amounts.count >= maxCount { return .full }
        return nil
    }

    /// Repairs anything stored or received: drops invalid and duplicate values, caps the count,
    /// and falls back to the defaults when nothing usable is left, so logging always has a button.
    public static func sanitized(_ amounts: [Int]) -> [Int] {
        var seen = Set<Int>()
        let valid = amounts.filter { range.contains($0) && seen.insert($0).inserted }.prefix(maxCount)
        return valid.isEmpty ? defaults : Array(valid)
    }

    /// "100,250,500". Kept as a string so SwiftData adds the column with a plain default.
    static func encode(_ amounts: [Int]) -> String {
        amounts.map(String.init).joined(separator: ",")
    }

    static func decode(_ raw: String) -> [Int] {
        sanitized(raw.split(separator: ",").compactMap { Int($0) })
    }
}
