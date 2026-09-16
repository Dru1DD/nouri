import Foundation

public enum Format {
    /// "1.65"
    public static func liters(_ ml: Double) -> String {
        (ml / 1000).formatted(.number.precision(.fractionLength(2)))
    }

    /// "1,420"
    public static func kcal(_ value: Double) -> String {
        Int(value.rounded()).formatted()
    }

    public static func ml(_ value: Double) -> String {
        Int(value.rounded()).formatted()
    }

    public static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
