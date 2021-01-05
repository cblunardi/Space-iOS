import Combine
import Foundation
import UIKit

extension ImageCacheServiceProtocol {
    func cachedImage<PublisherType>(with key: String, fallback: PublisherType)
        -> AnyPublisher<UIImage, PublisherType.Failure>
        where PublisherType: Publisher, PublisherType.Output == UIImage
    {
        guard let image = cachedImage(with: key) else {
            return fallback
                .handleEvents(receiveOutput: { [weak self] in self?.cacheImage($0, with: key) })
                .eraseToAnyPublisher()
        }

        return Just(image)
            .setFailureType(to: PublisherType.Failure.self)
            .eraseToAnyPublisher()
    }

    func cachedImage<PublisherType>(with key: String, fallback: PublisherType)
        -> AnyPublisher<UIImage?, PublisherType.Failure>
        where PublisherType: Publisher, PublisherType.Output == UIImage?
    {
        guard let image = cachedImage(with: key) else {
            return fallback
                .handleEvents(receiveOutput: { [weak self] in $0.map { self?.cacheImage($0, with: key) } })
                .eraseToAnyPublisher()
        }

        return Just(image)
            .setFailureType(to: PublisherType.Failure.self)
            .eraseToAnyPublisher()
    }
}
