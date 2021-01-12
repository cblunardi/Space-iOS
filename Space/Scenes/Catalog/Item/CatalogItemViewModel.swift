import Combine
import Foundation
import UIKit

struct CatalogItemViewModel: ViewModel, Identifiable, Hashable {
    private let timeFormatter: DateFormatter = Formatters.timeFormatter

    let entry: EPICImage
}

extension CatalogItemViewModel {
    var id: Int {
        entry.hashValue
    }

    var text: String? {
        timeFormatter.string(from: entry.date)
    }
}
