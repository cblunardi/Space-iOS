import UIKit

protocol Coordinator {
    associatedtype ViewControllerType: UIViewController

    var viewControllerReference: WeakReference<ViewControllerType> { get }

    init(viewControllerReference: WeakReference<ViewControllerType>)
}

extension Coordinator {
    var viewController: ViewControllerType? {
        viewControllerReference.value
    }

    init(viewController: ViewControllerType) {
        self.init(viewControllerReference: WeakReference(viewController))
    }

    func present(_ viewControllerToPresent: UIViewController,
                 completion: (() -> Void)? = nil)
    {
        viewController?.present(viewControllerToPresent,
                                animated: true,
                                completion: completion)
    }

    func close() {
        let presenting = viewController?.presentingViewController ?? viewController
        presenting?.dismiss(animated: true)
    }
}
