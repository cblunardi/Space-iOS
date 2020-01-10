import Combine
import Foundation
import UIKit

protocol ImageServiceProtocol: AnyObject {
    func retrieve(from url: URL) -> AnyPublisher<UIImage, Error>
    func prefetch(from url: URL)
}

final class ImageService: ImageServiceProtocol {
    private let cache: NSCache<NSURL, UIImage> = .configured()
    private let requestCache: NSCache<NSURL, Request> = .configured()

    func retrieve(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
        guard let image = cachedImage(with: url) else {
            return request(from: url)
        }

        return Just(image)
            .setFailureType(to: Swift.Error.self)
            .eraseToAnyPublisher()
    }

    func prefetch(from url: URL) {
        guard
            cachedImage(with: url) == nil,
            cachedRequest(with: url) == nil
        else {
            return
        }

        cacheRequest(.init(publisher: download(from: url)), with: url)
    }
}

private extension ImageService {
    enum Error: Swift.Error {
        case imageDecoding
    }

    func request(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
        let request: Request

        if let cached = cachedRequest(with: url) {
            request = cached
        } else {
            request = .init(publisher: download(from: url))
            cacheRequest(request, with: url)
        }

        return Future { [weak self] promise in
            request.add(receiver: {
                promise($0)
                self?.removeCachedRequest(with: url)
            })
        }
        .eraseToAnyPublisher()
    }

    func download(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
       dependencies.urlSessionService
            .perform(request: .init(url: url))
            .map { UIImage(data: $0.data) }
            .mapError { $0 as Swift.Error}
            .unwrap(or: Error.imageDecoding)
            .handleEvents(receiveOutput: { [weak self] in self?.cacheImage($0, with: url) },
                          receiveCompletion: { _ in })
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()

    }
}

fileprivate final class Request {
    typealias Receiver = (Result<UIImage, Swift.Error>) -> Void

    private var cancellable: AnyCancellable?
    var result: Result<UIImage, Swift.Error>?
    var receivers: [Receiver] = .empty

    init(publisher: AnyPublisher<UIImage, Swift.Error>) {
        cancellable = publisher
            .first()
            .sink(receiveCompletion: { [weak self] in self?.receive(completion: $0) },
                  receiveValue: { [weak self] in self?.receive(output: $0) })
    }

    private func receive(completion: Subscribers.Completion<Swift.Error>) {
        switch completion {
        case .finished:
            break
        case let .failure(error):
            result = .failure(error)
            receivers.forEach { $0(.failure(error)) }
        }

        receivers.removeAll()
    }

    private func receive(output: UIImage) {
        result = .success(output)
        receivers.forEach { $0(.success(output)) }
        receivers.removeAll()
    }

    func add(receiver: @escaping Receiver) {
        receivers.append(receiver)
        result.map { receiver($0) }
    }
}

private extension ImageService {
    func cacheImage(_ image: UIImage, with key: URL) {
        cache.setObject(image, forKey: key as NSURL, cost: image.cacheCost)
    }

    func cachedImage(with key: URL) -> UIImage? {
        cache.object(forKey: key as NSURL)
    }

    func cacheRequest(_ request: Request, with key: URL) {
        requestCache.setObject(request, forKey: key as NSURL)
    }

    func cachedRequest(with key: URL) -> Request? {
        requestCache.object(forKey: key as NSURL)
    }

    func removeCachedRequest(with key: URL) {
        requestCache.removeObject(forKey: key as NSURL)
    }
}

private extension NSCache where KeyType == NSURL, ObjectType == UIImage {
    static func configured() -> NSCache<NSURL, UIImage> {
        let cache = NSCache<NSURL, UIImage>()
        cache.totalCostLimit = 1 * .gigabyte
        return cache
    }
}

private extension NSCache where KeyType == NSURL, ObjectType == Request {
    static func configured() -> NSCache<NSURL, Request> {
        .init()
    }
}

private extension UIImage {
    var cacheCost: Int {
        Int(size.height) * (cgImage?.bytesPerRow ?? Int(size.width) * 4)
    }
}
