import UIKit

protocol CatalogCoordinatorProtocol {
    func close()

    func showExtendedCatalog(model: MonthCatalogViewModel.Model) -> MonthCatalogViewModelInterface
}

struct CatalogCoordinator: NavigationCoordinator, CatalogCoordinatorProtocol {
    var viewControllerReference: WeakReference<UINavigationController>

    func showExtendedCatalog(model: MonthCatalogViewModel.Model) -> MonthCatalogViewModelInterface {
        let viewController: MonthCatalogViewController = .instantiate()
        let coordinator: MonthCatalogCoordinator = .init(viewController: viewController)
        let viewModel: MonthCatalogViewModel = .init(model: model, coordinator: coordinator)
        viewController.viewModel = viewModel

        push(viewController)

        return viewModel
    }
}
