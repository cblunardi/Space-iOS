import Combine
import UIKit

final class CatalogMonthCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogMonthCell"

    var viewModel: CatalogMonthViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var containerStackView: UIStackView!

    private lazy var items: [UIView] = containerStackView
        .arrangedSubviews
        .compactMap { $0 as? UIStackView }
        .flatMap(\.arrangedSubviews)

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
            .enumerated()
            .forEach { $0.element.backgroundColor = viewModel.color(for: $0.offset) }
    }
}
