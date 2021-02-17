import UIKit

extension Coordinator {
    func showAlert(_ model: AlertModel) {
        let controller = model.materialize()

        present(controller)
    }
}

private extension AlertModel {
    func materialize() -> UIAlertController {
        let alert: UIAlertController =
            .init(title: title,
                  message: message,
                  preferredStyle: style)

        actions.forEach(alert.addAction(_:))

        return alert
    }
}
