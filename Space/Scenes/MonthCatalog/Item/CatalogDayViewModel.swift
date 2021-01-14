import Combine
import Foundation
import UIKit

struct CatalogDayViewModel: ViewModel, Identifiable, Hashable {
    private let timeFormatter: DateFormatter = Formatters.shortTimeFormatter

    let model: DateCatalog<EPICImage>.Day
    let selected: Bool
}

extension CatalogDayViewModel {
    var id: Int {
        model.hashValue
    }

    var text: String? {
        model.localizedDate
    }

    var backgroundColor: UIColor {
        selected ? .systemRed : .darkGray
    }
}
