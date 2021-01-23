import UIKit

extension UIImage {
    func transparent(with color: UIColor) -> UIImage? {
        color.cgColor.components
            .flatMap { cgImage?.copy(maskingColorComponents: $0) }
            .map(UIImage.init(cgImage:))
    }
}
