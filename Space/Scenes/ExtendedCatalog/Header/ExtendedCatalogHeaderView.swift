import UIKit

final class ExtendedCatalogHeaderView: UICollectionReusableView, ViewModelOwner {
    static let reuseIdentifier: String = "ExtendedCatalogHeaderView"

    var viewModel: ExtendedCatalogHeaderViewModel!

    @IBOutlet private var label: UILabel!

    func bind(viewModel: ExtendedCatalogHeaderViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.title
    }
}
