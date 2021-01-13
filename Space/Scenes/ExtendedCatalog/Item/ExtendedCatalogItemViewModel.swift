import Combine
import Foundation
import UIKit

struct ExtendedCatalogItemViewModel: ViewModel, Identifiable, Hashable {
    private let timeFormatter: DateFormatter = Formatters.shortTimeFormatter

    let entry: EPICImage

    let selected: Bool
}

extension ExtendedCatalogItemViewModel {
    var id: Int {
        entry.hashValue
    }

    var text: String? {
        timeFormatter.string(from: entry.date)
    }

    var backgroundColor: UIColor {
        selected ? .systemRed : .darkGray
    }
}
