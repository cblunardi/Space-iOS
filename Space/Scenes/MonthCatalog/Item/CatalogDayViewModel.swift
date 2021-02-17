import Combine
import Foundation
import UIKit

struct CatalogDayViewModel: ViewModel, Identifiable, Hashable {
    let formatter: DateFormatter = Formatters.dayFormatter

    let model: Model
}

extension CatalogDayViewModel {
    struct Model: Hashable {
        let month: DateCatalog<EPICImage>.Month
        let calendarDay: DateCatalog<EPICImage>.CalendarDay
    }
}

extension CatalogDayViewModel {
    var id: Int {
        model.hashValue
    }

    var text: String? {
        model.calendarDay.day.flatMap { formatter.string(from: $0.date) }
    }

    var image: UIImage? {
        isValidDay && !hasDay ? UIImage(systemName: "eye.slash") : .none
    }

    var backgroundColor: UIColor {
        model.calendarDay.color
    }
}

private extension CatalogDayViewModel {
    var isValidDay: Bool {
        model.month.daysRange.contains(model.calendarDay.index)
    }

    var hasDay: Bool {
        model.calendarDay.day != nil
    }
}
