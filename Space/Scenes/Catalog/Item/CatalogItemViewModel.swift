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

    var imageURL: URL? {
        URL(string: entry.uri)
    }

    var image: AnyPublisher<UIImage?, Never> {
        guard let url = imageURL else {
            return Just(nil).eraseToAnyPublisher()
        }

        return dependencies.imageService.retrieveAndProcess(from: url)
    }

    var text: String? {
        timeFormatter.string(from: entry.date)
    }
}
