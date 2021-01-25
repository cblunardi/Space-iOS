import UIKit

protocol MonthCatalogCoordinatorProtocol {
    func close()
}

struct MonthCatalogCoordinator: Coordinator, MonthCatalogCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>
}
