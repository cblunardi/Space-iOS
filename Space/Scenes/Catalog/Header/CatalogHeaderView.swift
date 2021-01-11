import UIKit

final class CatalogHeaderView: UICollectionReusableView, ViewModelOwner {
    var viewModel: CatalogHeaderViewModel!

    @IBOutlet private var label: UILabel!

    func bind(viewModel: CatalogHeaderViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.title
    }
}
