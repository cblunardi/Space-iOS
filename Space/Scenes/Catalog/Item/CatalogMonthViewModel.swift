import Combine
import Foundation
import UIKit

struct CatalogMonthViewModel: ViewModel, Identifiable, Hashable {
    let formatter: DateFormatter = Formatters.monthFormatter

    let month: DateCatalog<EPICImage>.Month

    let selectedDay: DateCatalog<EPICImage>.Day?
}

extension CatalogMonthViewModel {
    var id: Int {
        month.hashValue
    }

    var text: String? {
        formatter.string(from: month.date)
    }

    func color(for dayIndex: Int) -> UIColor {
        month.color(for: dayIndex, selectedDay: selectedDay)
    }
}
