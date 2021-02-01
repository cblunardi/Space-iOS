import Combine
import Foundation
import UIKit

struct CatalogMonthViewModel: ViewModel, Identifiable, Hashable {
    let formatter: DateFormatter = Formatters.monthFormatter

    let month: DateCatalog<EPICImage>.Month
    let calendarDays: [DateCatalog<EPICImage>.CalendarDay]
}

extension CatalogMonthViewModel {
    init(month: DateCatalog<EPICImage>.Month,
         selectedDay: DateCatalog<EPICImage>.Day?)
    {
        self.month = month
        calendarDays = month.calendarDays(selectedDay: selectedDay)
    }
}

extension CatalogMonthViewModel {
    var id: Int {
        month.hashValue
    }

    var text: String? {
        formatter.string(from: month.date)
    }

    func color(for dayIndex: Int) -> UIColor {
        calendarDays[safe: dayIndex]?.color ?? .clear
    }
}
