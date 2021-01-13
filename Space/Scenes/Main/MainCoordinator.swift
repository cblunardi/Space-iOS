import UIKit

protocol MainCoordinatorProtocol {
    func showCatalog(model: ExtendedCatalogViewModel.Model) -> ExtendedCatalogViewModelInterface
}

struct MainCoordinator: Coordinator, MainCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>

    @discardableResult func showCatalog(model: ExtendedCatalogViewModel.Model) -> ExtendedCatalogViewModelInterface {
        let viewController: ExtendedCatalogViewController = .instantiate()
        let coordinator: ExtendedCatalogCoordinator = .init(viewController: viewController)
        let viewModel: ExtendedCatalogViewModel = .init(model: model, coordinator: coordinator)
        viewController.viewModel = viewModel

        present(viewController)

        return viewModel
    }
}
