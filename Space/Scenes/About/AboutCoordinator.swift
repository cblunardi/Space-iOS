import UIKit

protocol AboutCoordinatorProtocol {
    func showAcknowledgements()
}

struct AboutCoordinator: NavigationCoordinator, AboutCoordinatorProtocol {
    var viewControllerReference: WeakReference<UINavigationController>

    func showAcknowledgements() {
        let viewController: AcknowledgementsViewController = .instantiate()
        let viewModel: AcknowledgementsViewModel = .init()
        viewController.viewModel = viewModel

        push(viewController)
    }
}
