import Foundation

extension Formatters {
    static func buildEPICDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: .zero)
        return formatter
    }

    static func buildEPICParameterNumberFormatter() -> NumberFormatter {
        let formatter: NumberFormatter = .init()
        formatter.maximumIntegerDigits = 4
        formatter.minimumIntegerDigits = 2
        return formatter
    }
}
