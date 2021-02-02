import UIKit

struct AlertModel {
    let title: String?
    let message: String?
    let style: UIAlertController.Style
    let actions: [UIAlertAction]
}

extension AlertModel {
    init(title: String? = .none,
         message: String? = .none,
         actions: [UIAlertAction] = .default)
    {
        self.init(title: title,
                  message: message,
                  style: .alert,
                  actions: actions)
    }
}

private extension Array where Element == UIAlertAction {
    static var `default`: [UIAlertAction] {
        [
            UIAlertAction(title: Localized.alertDefaultAction(),
                          style: .default,
                          handler: nil)
        ]
    }
}
