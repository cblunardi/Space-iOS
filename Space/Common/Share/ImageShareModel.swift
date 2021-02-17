import UIKit

struct ShareModel {
    let elements: [Any]

    init(text: String? = .none, image: UIImage? = .none) {
        var elements: [Any] = .empty

        text.map { elements.append($0) }
        image.map { elements.append($0) }

        self.elements = elements
    }
}
