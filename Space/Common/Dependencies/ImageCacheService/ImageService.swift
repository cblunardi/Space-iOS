import Combine
import Foundation
import UIKit

protocol ImageServiceProtocol: AnyObject {
    func retrieve(from url: URL) -> AnyPublisher<UIImage, Error>
}

final class ImageService: ImageServiceProtocol {
    private let cache: NSCache<NSURL, UIImage> = .configured()

    func retrieve(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
        guard let image = cachedImage(with: url) else {
            return download(from: url)
        }

        return Just(image)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }
}

private extension ImageService {
    enum Error: Swift.Error {
        case imageDecoding
    }

    func download(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
       dependencies.urlSessionService
            .perform(request: .init(url: url))
            .map { UIImage(data: $0.data) }
            .mapError { $0 as Swift.Error}
            .unwrap(or: Error.imageDecoding)
            .handleEvents(receiveOutput: { [weak self] in self?.cacheImage($0, with: url) })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

    }
}


private extension ImageService {
    func cacheImage(_ image: UIImage, with key: URL) {
        cache.setObject(image, forKey: key as NSURL, cost: image.cacheCost)
    }

    func cachedImage(with key: URL) -> UIImage? {
        cache.object(forKey: key as NSURL)
    }
}

private extension NSCache where KeyType == NSURL, ObjectType == UIImage {
    static func configured() -> NSCache<NSURL, UIImage> {
        let cache = NSCache<NSURL, UIImage>()
        cache.totalCostLimit = 512 * .megabyte
        return cache
    }
}

private extension UIImage {
    var cacheCost: Int {
        Int(size.height) * (cgImage?.bytesPerRow ?? Int(size.width) * 4)
    }
}
