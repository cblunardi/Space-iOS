import UIKit

enum ShareModel {
    case text(String)
    case image(UIImage)
}

extension ShareModel {
    var items: [Any] {
        switch self {
        case let .image(image):
            return [image]
        case let .text(text):
            return [text]
        }
    }
}
