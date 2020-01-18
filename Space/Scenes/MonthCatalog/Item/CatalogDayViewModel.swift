import Combine
import Foundation
import UIKit

struct CatalogDayViewModel: ViewModel, Identifiable, Hashable {
    let model: Model
}

extension CatalogDayViewModel {
    struct Model: Hashable {
        let month: DateCatalog<EPICImage>.Month
        let day: DateCatalog<EPICImage>.Day?
        let index: Int

        let selectedDay: DateCatalog<EPICImage>.Day?
    }
}

extension CatalogDayViewModel {
    var id: Int {
        model.hashValue
    }

    var text: String? {
        model.day?.localizedDate
    }

    var image: UIImage? {
        isValidDay && !hasDay ? UIImage(systemName: "eye.slash") : .none
    }

    var backgroundColor: UIColor {
        model.month.color(for: model.index, selectedDay: model.selectedDay)
    }
}

private extension CatalogDayViewModel {
    var isValidDay: Bool {
        model.month.isDayIndexValid(model.index)
    }

    var hasDay: Bool {
        model.month.day(from: model.index) != .none
    }
}
