import Combine
import UIKit

extension ImageServiceProtocol {
    func retrieveAndProcess(from url: URL) -> AnyPublisher<UIImage?, Never> {
        if let image = cachedImage(with: url) {
            return Just(image).eraseToAnyPublisher()
        }

        let empty: AnyPublisher<UIImage?, Never> = Just(nil)
            .eraseToAnyPublisher()

        let retrieve: AnyPublisher<UIImage?, Never> = dependencies.imageService
            .retrieve(from: url)
            .map { Optional($0) }
            .replaceError(with: nil)
            .eraseToAnyPublisher()

        return Publishers.Concatenate(prefix: empty, suffix: retrieve)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
