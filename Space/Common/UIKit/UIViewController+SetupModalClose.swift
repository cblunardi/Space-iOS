import Combine
import UIKit

extension UIViewController {
    func setupCloseButton() {
        let closeButton: UIBarButtonItem = .init(barButtonSystemItem: .close,
                                                 target: self,
                                                 action: #selector(close))

        navigationItem.setLeftBarButton(closeButton, animated: false)
    }

    @objc private func close() {
        guard navigationController?.viewControllers == [self] else {
            dismiss(animated: true)
            return
        }
        navigationController?.dismiss(animated: true)
    }
}
