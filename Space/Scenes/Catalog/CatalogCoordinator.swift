import UIKit

protocol CatalogCoordinatorProtocol {
    func close()
}

struct CatalogCoordinator: Coordinator, CatalogCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>
}
