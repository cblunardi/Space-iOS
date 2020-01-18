import Foundation

struct Formatters {
    static let calendar: Calendar = .current

    static let dateFormatter: DateFormatter = buildDateFormatter()
    static func buildDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    static let timeFormatter: DateFormatter = buildTimeFormatter()
    static func buildTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    static let yearFormatter: DateFormatter = buildYearFormatter()
    static func buildYearFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter
    }

    static let monthFormatter: DateFormatter = buildMonthFormatter()
    static func buildMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }

    static let longMonthFormatter: DateFormatter = buildLongMonthFormatter()
    static func buildLongMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }

    static let dayFormatter: DateFormatter = buildDayFormatter()
    static func buildDayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }
}
