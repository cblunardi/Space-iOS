import Foundation

struct Formatters {
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
}
