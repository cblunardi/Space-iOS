import UIKit

extension DateCatalog.Month {
    var dayNumbers: Range<Int>? {
        guard
            let calendar = components.calendar,
            let date = date
        else {
            return nil
        }

        return calendar.range(of: .day, in: .month, for: date)
    }

    var firstWeekdayIndex: Int {
        guard
            let date = self.date,
            let firstWeekDay = components.calendar?.component(.weekday, from: date)
        else {
            return .zero
        }

        return firstWeekDay - 1
    }

    func isDayIndexValid(_ dayIndex: Int) -> Bool {
        dayNumbers?.contains(dayNumber(from: dayIndex)) == true
    }

    func day(from dayIndex: Int) -> DateCatalog.Day? {
        days.first(where: { $0.components.day == dayNumber(from: dayIndex) })
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
        dayIndex - firstWeekdayIndex + 1
    }
}
