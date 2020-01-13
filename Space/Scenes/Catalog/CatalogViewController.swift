import Combine
import UIKit

final class CatalogViewController: UIViewController, ViewModelOwner, StoryboardLoadable {
    typealias DataSource = UICollectionViewDiffableDataSource<CatalogViewModel.Section, CatalogItemViewModel>

    private lazy var dataSource = makeDataSource()

    private var subscriptions: Set<AnyCancellable> = .init()

    var viewModel: CatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: CatalogViewModel) {
        subscriptions.removeAll()

        viewModel.snapshot
            .sink { [weak self] in
                self?.dataSource.apply($0.snapshot)

                guard let index = $0.selectedIndex else { return }
                self?.collectionView.scrollToItem(at: index,
                                                  at: .centeredVertically,
                                                  animated: false)
            }
            .store(in: &subscriptions)
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
                let self = self,
                let headerViewModel = self.viewModel
                    .supplementaryViewViewModel(of: kind,
                                                for: indexPath,
                                                using: self.dataSource.snapshot())
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
        collectionView.delegate = self
    }
}

extension CatalogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard
            let section = snapshot.sectionIdentifiers[safe: indexPath.section],
            let item = snapshot.itemIdentifiers(inSection: section)[safe: indexPath.item]
        else { return }

        viewModel.didSelect(item: item)
    }
}

private extension UICollectionViewCompositionalLayout {
    static func build() -> UICollectionViewCompositionalLayout {

        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(65),
                                                     heightDimension: .absolute(65))
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(65))
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        group.interItemSpacing = .fixed(3)

        let headerSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: headerSize,
                                                                        elementKind: "Header",
                                                                        alignment: .topLeading)

        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 3

        return .init(section: section)
    }
}
