import UIKit

protocol CatalogCoordinatorProtocol {
    func close()

    func showExtendedCatalog(model: ExtendedCatalogViewModel.Model) -> ExtendedCatalogViewModelInterface
}

struct CatalogCoordinator: NavigationCoordinator, CatalogCoordinatorProtocol {
    var viewControllerReference: WeakReference<UINavigationController>

    func showExtendedCatalog(model: ExtendedCatalogViewModel.Model) -> ExtendedCatalogViewModelInterface {
        let viewController: ExtendedCatalogViewController = .instantiate()
        let coordinator: ExtendedCatalogCoordinator = .init(viewController: viewController)
        let viewModel: ExtendedCatalogViewModel = .init(model: model, coordinator: coordinator)
        viewController.viewModel = viewModel

        push(viewController)

        return viewModel
    }
}
