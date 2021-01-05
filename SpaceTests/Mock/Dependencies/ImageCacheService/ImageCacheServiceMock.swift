@testable import Space
import Combine
import Foundation
import UIKit

final class ImageCacheServiceMock: ImageCacheServiceProtocol {
    var cachedImageBehaviour: (String) -> UIImage? = { _ in nil }
    func cachedImage(with key: String) -> UIImage? {
        cachedImageBehaviour(key)
    }

    var cacheImageBehaviour: (UIImage, String) -> Void = { _, _ in }
    func cacheImage(_ image: UIImage, with key: String) {
        cacheImageBehaviour(image, key)
    }
}
