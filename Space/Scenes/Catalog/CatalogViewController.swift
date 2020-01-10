import Combine
import UIKit

final class CatalogViewController: UIViewController, ViewModelOwner {
    var viewModel: CatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    func bind(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
    }
}
