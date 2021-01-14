import Combine
import Foundation
import UIKit

struct CatalogMonthViewModel: ViewModel, Identifiable, Hashable {
    let month: DateCatalog<EPICImage>.Month

    let selectedDay: DateCatalog<EPICImage>.Day?
}

extension CatalogMonthViewModel {
    var id: Int {
        month.hashValue
    }

    var text: String? {
        month.localizedDate
    }

    func color(for dayIndex: Int) -> UIColor {
        let dayOffset = dayIndex - month.firstWeekday
        guard month.daysRangeInMonth?.contains(dayOffset) == true else {
            return .clear
        }

        guard let day = month.days.first(where: { $0.components.day == dayOffset }) else {
            return .darkGray
        }

        guard selectedDay == day else {
            return .lightGray
        }

        return .systemRed
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
