import Foundation

struct Formatters {
    static let calendar: Calendar = .init(identifier: .gregorian)

    static let shortFormatter: DateFormatter = buildShortFormatter()
    static func buildShortFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("dMMM")
        return formatter
    }

    static let mediumFormatter: DateFormatter = buildMediumFormatter()
    static func buildMediumFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("dMMMhh")
        return formatter
    }

    static let longFormatter: DateFormatter = buildLongFormatter()
    static func buildLongFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("dMMMYYYYhhmm")
        return formatter
    }

    static let dateFormatter: DateFormatter = buildDateFormatter()
    static func buildDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("ddMMYYYY")
        return formatter
    }

    static let timeFormatter: DateFormatter = buildTimeFormatter()
    static func buildTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("hhmm")
        return formatter
    }

    static let yearFormatter: DateFormatter = buildYearFormatter()
    static func buildYearFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("yyyy")
        return formatter
    }

    static let monthFormatter: DateFormatter = buildMonthFormatter()
    static func buildMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("MMM")
        return formatter
    }

    static let longMonthFormatter: DateFormatter = buildLongMonthFormatter()
    static func buildLongMonthFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("MMMM")
        return formatter
    }

    static let dayFormatter: DateFormatter = buildDayFormatter()
    static func buildDayFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }
}
