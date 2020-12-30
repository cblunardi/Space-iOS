import UIKit

protocol Coordinator {
    associatedtype ViewControllerType: UIViewController

    var viewController: WeakReference<ViewControllerType> { get }

    init(viewController: WeakReference<ViewControllerType>)
}
