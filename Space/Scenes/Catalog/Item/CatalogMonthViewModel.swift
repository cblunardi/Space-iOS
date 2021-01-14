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

    var numberOfDays: Int {
        month.days.count
    }

    var selectedItemIndex: Int? {
        selectedDay.flatMap(month.days.firstIndex(of:))
    }
}
