import Combine
import UIKit

final class CatalogDayCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogDayCell"

    var viewModel: CatalogDayViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.cornerRadius = frame.width / 2
    }

    func bind(viewModel: CatalogDayViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text
        imageView.image = viewModel.image

        containerView.backgroundColor = viewModel.backgroundColor
    }
}
