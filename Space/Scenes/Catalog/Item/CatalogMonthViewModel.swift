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
        month.color(for: dayIndex, selectedDay: selectedDay)
    }
}
