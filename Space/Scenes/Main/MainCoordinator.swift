import UIKit

protocol MainCoordinatorProtocol {
    func showCatalog(model: CatalogViewModel.Model) -> CatalogViewModelInterface
    func showAbout()
}

struct MainCoordinator: Coordinator, MainCoordinatorProtocol {
    var viewControllerReference: WeakReference<UIViewController>

    @discardableResult func showCatalog(model: CatalogViewModel.Model) -> CatalogViewModelInterface {
        let viewController: CatalogViewController = .instantiate()
        let coordinator: CatalogCoordinator = .init(root: viewController)
        let viewModel: CatalogViewModel = .init(model: model, coordinator: coordinator)
        viewController.viewModel = viewModel

        coordinator.viewController.map { present($0) }

        return viewModel
    }

    func showAbout() {
        let viewController: AboutViewController = .instantiate()
        let viewModel: AboutViewModel = .init()
        viewController.viewModel = viewModel

        present(viewController)
    }
}
