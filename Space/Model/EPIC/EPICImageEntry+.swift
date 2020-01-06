import Foundation

extension EPICImageEntry {
    var swiftDate: Date? {
        Formatters.epicDateFormatter.date(from: date)
    }
}
