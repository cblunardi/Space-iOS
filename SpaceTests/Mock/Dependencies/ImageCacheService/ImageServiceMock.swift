@testable import Space
import Combine
import Foundation
import UIKit

final class ImageServiceMock: ImageServiceProtocol {
    var retrieveBehaviour: (URL) -> AnyPublisher<UIImage, Error> = { _ in .mockFailure }
    func retrieve(from url: URL) -> AnyPublisher<UIImage, Error> {
        retrieveBehaviour(url)
    }

    var prefetchBehaviour: (URL) -> Void = { _ in }
    func prefetch(from url: URL) {
        prefetchBehaviour(url)
    }

    var cachedImageBehaviour: (URL) -> UIImage? = { _ in nil }
    func cachedImage(with key: URL) -> UIImage? {
        cachedImageBehaviour(key)
    }
}
