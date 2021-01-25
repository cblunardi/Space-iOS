import UIKit

protocol NavigationCoordinator: Coordinator where ViewControllerType == UINavigationController {
    func push(_ viewController: UIViewController)
}

extension NavigationCoordinator {
    init(root rootViewController: UIViewController) {
        self.init(viewController: .init(rootViewController: rootViewController))
    }

    func push(_ viewControllerToPush: UIViewController) {
        viewController?.pushViewController(viewControllerToPush, animated: true)
    }
}
