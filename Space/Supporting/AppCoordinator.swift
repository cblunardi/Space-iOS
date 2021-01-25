import UIKit

struct AppCoordinator: Coordinator {
    var viewControllerReference: WeakReference<UIViewController> = .init()

    func start(in window: UIWindow) {
        let viewController = MainViewController.instantiate()
        let coordinator: MainCoordinator =  .init(viewController: viewController)
        let viewModel = MainViewModel(coordinator: coordinator)
        viewController.viewModel = viewModel

        window.rootViewController = viewController
    }
}
