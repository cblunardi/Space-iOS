import UIKit

protocol ExtendedCatalogCoordinatorProtocol {
    func close()
}

struct ExtendedCatalogCoordinator: Coordinator, ExtendedCatalogCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>
}
