import UIKit

extension DateCatalog.Month {
    var daysRange: Range<Int> {
        Formatters.calendar.range(of: .day, in: .month, for: date)
            ?? 1 ..< 32
    }

    func calendarDays(selectedDay: DateCatalog.Day? = nil) -> [DateCatalog.CalendarDay] {
        (2 - firstDayWeekday ..< daysRange.upperBound)
            .map {
                .init(index: $0,
                      day: day(from: $0),
                      color: color(for: $0, selectedDay: selectedDay))
            }
    }

    /*
     = weekdayOffset = 2 - Month.firstWeekday

    0   1   2   3   4   5   6
    7   8   9   10  11  12  13

    Month.firstWeekday = 1
    weekdayOffset = 1
    1   2   3   4   5   6   7
    8   9   10  11  12  13  14

    1   2   3   4   5   6   7
    8   9   10  11  12  13  14


    Month.firstWeekday = 3
    weekdayOffset = -1
    x   x   1   2   3   4   5
    6   7   8   9   10  11  12

    -1  0   1   2   3   4   5
    6   7   8   9   10  11  12


    Month.firstWeekday = 7
    weekdayOffset = -5
    x   x   x   x   x   x   1
    2   3   4   5   6   7   8

    -5  -4  -3  -2  -1  0   1
    2   3   4   5   6   7   8

    */
}

private extension DateCatalog.Month {
    var firstDayWeekday: Int {
        Formatters.calendar.component(.weekday, from: date)
    }

    func day(from dayNumber: Int) -> DateCatalog.Day? {
        days.first(where: { $0.dateComponents.day == dayNumber })
    }

    func color(for dayNumber: Int, selectedDay: DateCatalog.Day? = .none) -> UIColor {
        guard daysRange.contains(dayNumber) else {
            return .clear
        }

        guard let day = day(from: dayNumber) else {
            return Colors.disabled
        }

        guard selectedDay == day else {
            return Colors.palette3
        }

        return Colors.palette5
    }
}

extension DateCatalog {
    struct CalendarDay: Hashable {
        let index: Int
        let day: Day?

        let color: UIColor
    }
}
