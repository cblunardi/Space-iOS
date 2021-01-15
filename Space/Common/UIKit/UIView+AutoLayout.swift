import UIKit

extension UIView {
    func snap(to otherView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: otherView.leadingAnchor),
            trailingAnchor.constraint(equalTo: otherView.trailingAnchor),
            topAnchor.constraint(equalTo: otherView.topAnchor),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor)
        ])
    }
}
