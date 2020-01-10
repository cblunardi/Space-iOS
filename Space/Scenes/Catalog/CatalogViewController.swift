import Combine
import UIKit

final class CatalogViewController: UIViewController, ViewModelOwner {
    typealias DataSource = UICollectionViewDiffableDataSource<CatalogViewModel.Section, CatalogItemViewModel>

    private lazy var dataSource = makeDataSource()
    private var isViewModelBinded: Bool = false
    var viewModel: CatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()

        guard isViewModelBinded == false, viewModel != nil else { return }
        bind(viewModel: viewModel)
    }

    func bind(viewModel: CatalogViewModel) {
        self.viewModel = viewModel

        guard isViewLoaded else { return }

        isViewModelBinded = true

        dataSource.apply(viewModel.snapshot)
    }
}

private extension CatalogViewController {
    func makeDataSource() -> DataSource {
        .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "CatalogItemCell", for: indexPath) as? CatalogItemCell
            cell?.bind(viewModel: item)
            return cell
        }
    }

    func setupCollectionView() {
        collectionView.register(UINib(nibName: "CatalogItemCell", bundle: .main),
                                forCellWithReuseIdentifier: "CatalogItemCell")

        collectionView.dataSource = dataSource
    }
}
