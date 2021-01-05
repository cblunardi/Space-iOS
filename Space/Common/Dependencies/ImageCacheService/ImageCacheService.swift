import Foundation
import UIKit

protocol ImageCacheServiceProtocol: AnyObject {
    func cachedImage(with key: String) -> UIImage?
    func cacheImage(_ image: UIImage, with key: String)
}

final class ImageCacheService: ImageCacheServiceProtocol {
    private let cache: NSCache<NSString, UIImage> = .configured()

    func cacheImage(_ image: UIImage, with key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func cachedImage(with key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
}

private extension NSCache where KeyType == NSString, ObjectType == UIImage {
    static func configured() -> NSCache<NSString, UIImage> {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 512 * .megabyte
        return cache
    }
}
