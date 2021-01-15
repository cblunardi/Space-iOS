import UIKit

extension DateCatalog.Month {
    func color(for dayIndex: Int, selectedDay: DateCatalog.Day? = .none) -> UIColor {
        let dayOffset = dayIndex - firstWeekday
        guard daysRangeInMonth?.contains(dayOffset) == true else {
            return .clear
        }

        guard let day = days.first(where: { $0.components.day == dayOffset }) else {
            return Colors.Catalog.dayUnavailable
        }

        guard selectedDay == day else {
            return Colors.Catalog.day
        }

        return Colors.Catalog.daySelected
    }
}

private extension DateCatalog.Month {
    var daysRangeInMonth: Range<Int>? {
        guard
            let calendar = components.calendar,
            let date = date
        else {
            return nil
        }

        return calendar.range(of: .day, in: .month, for: date)
    }

    var firstWeekday: Int {
        guard let date = self.date else { return .zero }
        return components.calendar?.component(.weekday, from: date) ?? .zero
    }
}
