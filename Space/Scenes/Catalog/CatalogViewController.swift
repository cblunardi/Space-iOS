import Combine
import UIKit

final class CatalogViewController: UIViewController, ViewModelOwner, StoryboardLoadable {
    typealias DataSource = UICollectionViewDiffableDataSource<CatalogViewModel.Section, CatalogItemViewModel>

    private lazy var dataSource = makeDataSource()

    var viewModel: CatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: CatalogViewModel) {
        dataSource.apply(viewModel.snapshot)
    }
}

private extension CatalogViewController {
    func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection.dequeueReusableCell(withReuseIdentifier: "CatalogItemCell", for: indexPath) as? CatalogItemCell
            cell?.bind(viewModel: item)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collection, kind, indexPath in
            guard
                let headerViewModel = self?.viewModel.supplementaryViewViewModel(of: kind, for: indexPath)
            else {
                return nil
            }

            let view = collection.dequeueReusableSupplementaryView(ofKind: "Header",
                                                                   withReuseIdentifier: "CatalogHeaderView",
                                                                   for: indexPath) as? CatalogHeaderView

            view?.bind(viewModel: headerViewModel)

            return view
        }
        return dataSource
    }

    func setupCollectionView() {
        collectionView.register(UINib(nibName: "CatalogItemCell", bundle: .main),
                                forCellWithReuseIdentifier: "CatalogItemCell")

        collectionView.register(UINib(nibName: "CatalogHeaderView", bundle: .main),
                                forSupplementaryViewOfKind: "Header",
                                withReuseIdentifier: "CatalogHeaderView")

        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout.build(),
                                               animated: false)

        collectionView.dataSource = dataSource
    }
}

private extension UICollectionViewCompositionalLayout {
    static func build() -> UICollectionViewCompositionalLayout {

        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .fractionalHeight(1.0))

        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(150),
                                                      heightDimension: .absolute(150))

        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let headerSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))

        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: headerSize,
                                                                        elementKind: "Header",
                                                                        alignment: .topLeading)

        let section: NSCollectionLayoutSection = .init(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [header]

        return .init(section: section)
    }
}
