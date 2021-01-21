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
        model.day.flatMap { formatter.string(from: $0.date) }
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
