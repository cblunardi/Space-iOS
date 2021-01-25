import UIKit

protocol AboutCoordinatorProtocol {
    func showAboutSpace()
    func showAcknowledgements()
}

struct AboutCoordinator: NavigationCoordinator, AboutCoordinatorProtocol {
    var viewControllerReference: WeakReference<UINavigationController>

    func showAboutSpace() {

    }

    func showAcknowledgements() {
        
    }
}
