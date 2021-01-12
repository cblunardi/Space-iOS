import Combine
import UIKit

final class CatalogItemCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogItemCell"

    var viewModel: CatalogItemViewModel!

    @IBOutlet private var label: UILabel!


    func bind(viewModel: CatalogItemViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text
    }
}
