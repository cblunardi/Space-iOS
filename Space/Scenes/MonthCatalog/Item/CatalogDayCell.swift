import Combine
import UIKit

final class CatalogDayCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogDayCell"

    var viewModel: CatalogDayViewModel!

    @IBOutlet private var backgroundImageView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var imageView: UIImageView!

    func bind(viewModel: CatalogDayViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text
        imageView.image = viewModel.image

        backgroundImageView.tintColor = viewModel.backgroundColor
    }
}
