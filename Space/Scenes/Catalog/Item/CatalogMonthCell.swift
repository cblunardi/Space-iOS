import Combine
import UIKit

final class CatalogMonthCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogMonthCell"

    var viewModel: CatalogMonthViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var containerStackView: UIStackView!

    private lazy var items: [UIImageView] = containerStackView
        .arrangedSubviews
        .compactMap { $0 as? UIStackView }
        .flatMap(\.arrangedSubviews)
        .compactMap { $0 as? UIImageView }

    func bind(viewModel: CatalogMonthViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text

        items
            .enumerated()
            .forEach { $0.element.tintColor = viewModel.color(for: $0.offset) }
    }
}
