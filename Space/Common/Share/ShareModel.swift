import UIKit

final class ShareModel: NSObject {
    private let all: [Any]
    private let text: String?
    private let image: UIImage?

    init(image: UIImage? = .none, text: String? = .none) {
        let all: [Any?] = [image, text]

        self.image  =  image
        self.text = text
        self.all = all.compactMap { $0 }
    }
}

extension ShareModel: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController)
    -> Any
    {
        image as Any
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?)
    -> Any?
    {
        image as Any
    }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?)
    -> String
    {
        text ?? .empty
    }
}
