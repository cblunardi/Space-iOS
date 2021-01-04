import UIKit

struct AppCoordinator: Coordinator {
    var viewController: WeakReference<UIViewController> = .init()

    func start(in window: UIWindow) {
        let viewModel = MainViewModel()
        let viewController = MainViewController.instantiate()

        viewController.bind(viewModel: viewModel)

        window.rootViewController = viewController
    }
}
