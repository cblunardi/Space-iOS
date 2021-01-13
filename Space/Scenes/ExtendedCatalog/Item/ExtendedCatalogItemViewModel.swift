import Combine
import Foundation
import UIKit

struct ExtendedCatalogItemViewModel: ViewModel, Identifiable, Hashable {
    private let timeFormatter: DateFormatter = Formatters.timeFormatter

    let entry: EPICImage
}

extension ExtendedCatalogItemViewModel {
    var id: Int {
        entry.hashValue
    }

    var text: String? {
        timeFormatter.string(from: entry.date)
    }
}
