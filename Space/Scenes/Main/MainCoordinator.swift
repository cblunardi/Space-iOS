import UIKit

protocol MainCoordinatorProtocol {
    func showCatalog(model: CatalogViewModel.Model) -> CatalogViewModelInterface
}

struct MainCoordinator: Coordinator, MainCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>

    @discardableResult func showCatalog(model: CatalogViewModel.Model) -> CatalogViewModelInterface {
        let viewController: CatalogViewController = .instantiate()
        let coordinator: CatalogCoordinator = .init(viewController: viewController)
        let viewModel: CatalogViewModel = .init(model: model, coordinator: coordinator)
        viewController.viewModel = viewModel

        present(viewController)

        return viewModel
    }
}
