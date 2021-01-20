import Combine
import Foundation
import UIKit

protocol ImageServiceProtocol: AnyObject {
    func retrieve(from url: URL) -> AnyPublisher<UIImage, Error>
    func prefetch(from url: URL)

    func cachedImage(with key: URL) -> UIImage?
}

final class ImageService: ImageServiceProtocol {
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
            cachedRequest(with: url) == nil
        else {
            return
        }

        cacheRequest(.init(publisher: download(from: url)), with: url)
    }

    func cachedImage(with key: URL) -> UIImage? {
        try? cachedRequest(with: key)?.result?.get()
    }
}

private extension ImageService {
    enum Error: Swift.Error {
        case imageDecoding
    }

    func request(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
        let request: Request

        if let cached = cachedRequest(with: url), case .success = cached.result {
            request = cached
        } else {
            request = .init(publisher: download(from: url))
            cacheRequest(request, with: url)
        }

        return Future { promise in
            request.add(receiver: { promise($0) })
        }
        .eraseToAnyPublisher()
    }

    func download(from url: URL) -> AnyPublisher<UIImage, Swift.Error> {
       dependencies.urlSessionService
            .perform(request: .init(url: url))
            .validateHTTP()
            .map(UIImage.init(data:))
            .mapError { $0 as Swift.Error}
            .unwrap(or: Error.imageDecoding)
            .share()
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
    }

    func add(receiver: @escaping Receiver) {
        receivers.append(receiver)
        result.map { receiver($0) }
    }
}

private extension ImageService {
    func cacheRequest(_ request: Request, with key: URL) {
        requestCache.setObject(request, forKey: key as NSURL, cost: 2048 * 2048 * 4 * 2)
    }

    func cachedRequest(with key: URL) -> Request? {
        requestCache.object(forKey: key as NSURL)
    }

    func removeCachedRequest(with key: URL) {
        requestCache.removeObject(forKey: key as NSURL)
    }
}

private extension NSCache where KeyType == NSURL, ObjectType == Request {
    static func configured() -> NSCache<NSURL, Request> {
        let cache: NSCache<NSURL, Request> = .init()
        cache.totalCostLimit = 1 * .giga
        cache.countLimit = 50
        return cache
    }
}

private extension UIImage {
    var cacheCost: Int {
        cgImage.map { $0.bytesPerRow * $0.height }
            ?? Int(size.width * size.height * UIScreen.main.scale * 4)
    }
}
