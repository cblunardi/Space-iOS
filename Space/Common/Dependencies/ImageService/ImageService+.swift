import Combine
import UIKit

extension ImageServiceProtocol {
    func retrieveAndProcess(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cachedImage(with: url) {
            return Just(image).eraseToAnyPublisher()
        }

        let empty: AnyPublisher<UIImage?, Never> = Just(nil)
            .delay(for: .milliseconds(100), scheduler: RunLoop.main)
            .eraseToAnyPublisher()

        let retrieve: AnyPublisher<UIImage?, Never> = dependencies.imageService
            .retrieve(from: url)
            .map { Optional($0) }
            .replaceError(with: nil)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

        return Publishers.Merge(empty, retrieve)
            .prefix(while: { $0 != nil })
            .eraseToAnyPublisher()
    }
}
