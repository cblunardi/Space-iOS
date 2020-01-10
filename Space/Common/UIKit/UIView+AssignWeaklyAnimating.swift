import Combine
import UIKit

extension Publisher where Failure == Never {
    func assignWeakly<Object>(to keyPath: WritableKeyPath<Object, Output>,
                              on object: Object,
                              animationDuration: TimeInterval)
    -> AnyCancellable
    where Object: UIView
    {
        sink(receiveValue: { [weak object] output in
            UIView.animate(withDuration: animationDuration) {
                object?[keyPath: keyPath] = output
            }
        })
    }

    func assignWeakly<Object>(to keyPath: WritableKeyPath<Object, Output>,
                              on object: Object,
                              crossDissolveDuration: TimeInterval)
    -> AnyCancellable
    where Object: UIView
    {
        sink(receiveValue: { [weak object] output in
            guard let someObject = object else { return }
            UIView.transition(with: someObject,
                              duration: crossDissolveDuration,
                              options: [.transitionCrossDissolve, .beginFromCurrentState],
                              animations: {
                                object?[keyPath: keyPath] = output
                              }, completion: nil)
        })
    }
}
