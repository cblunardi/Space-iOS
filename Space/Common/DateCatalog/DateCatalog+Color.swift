import UIKit

extension DateCatalog.Month {
    var weeksRange: Range<Int>? {
        Formatters.calendar.range(of: .weekOfMonth, in: .month, for: date)
    }

    var daysRange: Range<Int>? {
        Formatters.calendar.range(of: .day, in: .month, for: date)
    }

    var firstWeekdayIndex: Int {
        Formatters.calendar.component(.weekday, from: date) - 1
    }

    func isDayIndexValid(_ dayIndex: Int) -> Bool {
        daysRange?.contains(dayNumber(from: dayIndex)) == true
    }

    func day(from dayIndex: Int) -> DateCatalog.Day? {
        days.first(where: { $0.dateComponents.day == dayNumber(from: dayIndex) })
    }

    func color(for dayIndex: Int, selectedDay: DateCatalog.Day? = .none) -> UIColor {
        guard isDayIndexValid(dayIndex) else {
            return .clear
        }

        guard let day = day(from: dayIndex) else {
            return Colors.disabled
        }

        guard selectedDay == day else {
            return Colors.palette3
        }

        return Colors.palette5
    }
}

private extension DateCatalog.Month {
    func dayNumber(from dayIndex: Int) -> Int {
        2 + dayIndex - firstWeekdayIndex
    }
}
