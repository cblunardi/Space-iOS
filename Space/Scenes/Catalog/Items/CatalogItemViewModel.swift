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
            return Empty().eraseToAnyPublisher()
        }

        let empty: AnyPublisher<UIImage?, Never> = Just(nil)
            .eraseToAnyPublisher()

        let image: AnyPublisher<UIImage?, Never> = dependencies.imageService
            .retrieve(from: url)
            .map { Optional($0) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()

        return Publishers.Merge(empty, image)
            .eraseToAnyPublisher()
    }

    var text: String? {
        timeFormatter.string(from: entry.date)
    }
}
