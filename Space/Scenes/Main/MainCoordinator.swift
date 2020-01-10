import UIKit

protocol MainCoordinatorProtocol {
    func showCatalog(model: CatalogViewModel.Model)
}

struct MainCoordinator: Coordinator, MainCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>

    func showCatalog(model: CatalogViewModel.Model) {
        let viewModel: CatalogViewModel = .init(model: model)
        let viewController: CatalogViewController = .instantiate()
        viewController.viewModel = viewModel

        present(viewController)
    }
}
