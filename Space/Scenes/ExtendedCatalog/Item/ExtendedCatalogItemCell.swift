import Combine
import UIKit

final class ExtendedCatalogItemCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "ExtendedCatalogItemCell"

    var viewModel: ExtendedCatalogItemViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = frame.width / 2
    }

    func bind(viewModel: ExtendedCatalogItemViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text

        containerView.backgroundColor = viewModel.backgroundColor
    }
}
