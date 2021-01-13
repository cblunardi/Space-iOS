import Combine
import UIKit

final class ExtendedCatalogItemCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "ExtendedCatalogItemCell"

    var viewModel: ExtendedCatalogItemViewModel!

    @IBOutlet private var label: UILabel!


    func bind(viewModel: ExtendedCatalogItemViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text
    }
}
