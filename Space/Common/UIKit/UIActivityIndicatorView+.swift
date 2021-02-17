import UIKit

extension UIActivityIndicatorView {
    var animating: Bool {
        get {
            !isHidden
        }
        set {
            isHidden = !newValue
            if newValue {
                startAnimating()
            } else {
                stopAnimating()
            }
        }
    }
}
