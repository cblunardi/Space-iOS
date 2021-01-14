import Combine
import UIKit

final class CatalogMonthCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogMonthCell"

    var viewModel: CatalogMonthViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var containerStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()

        items.forEach {
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        items.forEach {
            $0.layer.cornerRadius = $0.frame.width / 2
        }
    }

    func bind(viewModel: CatalogMonthViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text

        items
            .slice(safeRange: 0..<viewModel.numberOfDays)
            .forEach { $0.backgroundColor = .darkGray }

        items
            .slice(safeRange: viewModel.numberOfDays...)
            .forEach { $0.backgroundColor = .clear}

        viewModel
            .selectedItemIndex
            .flatMap { items[safe: $0] }?
            .backgroundColor = .systemRed
    }
}

private extension CatalogMonthCell {
    var items: [UIView] {
        containerStackView
            .arrangedSubviews
            .compactMap { $0 as? UIStackView }
            .flatMap(\.arrangedSubviews)
    }
}
