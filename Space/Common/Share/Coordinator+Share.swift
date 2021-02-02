import UIKit

extension Coordinator {
    func showShare(_ model: ShareModel,
                   completion: (() -> Void)? = nil)
    {
        let controller = UIActivityViewController(activityItems: model.items,
                                                  applicationActivities: nil)

        present(controller, completion: completion)
    }
}
