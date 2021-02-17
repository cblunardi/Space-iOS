import UIKit

extension Coordinator {
    func showShare(_ model: ShareModel,
                   source: PopoverPresentationSource,
                   completion: (() -> Void)? = nil)
    {
        let controller = UIActivityViewController(activityItems: model.items,
                                                  applicationActivities: nil)

        controller
            .popoverPresentationController
            .map(source.apply(to:))

        present(controller, completion: completion)
    }
}

enum PopoverPresentationSource {
    case view(UIView)
    case barButtonItem(UIBarButtonItem)

    func apply(to popover: UIPopoverPresentationController) {
        switch self {
        case let .view(view):
            popover.sourceView = view
        case let .barButtonItem(item):
            popover.barButtonItem = item
        }
    }
}
