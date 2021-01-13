import Combine
import UIKit

final class ExtendedCatalogViewController: UIViewController, ViewModelOwner, StoryboardLoadable {
    typealias DataSource = UICollectionViewDiffableDataSource<ExtendedCatalogViewModel.Section, ExtendedCatalogItemViewModel>

    private lazy var dataSource = makeDataSource()

    private var subscriptions: Set<AnyCancellable> = .init()

    var viewModel: ExtendedCatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: ExtendedCatalogViewModel) {
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

private extension ExtendedCatalogViewController {
    func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection
                .dequeueReusableCell(withReuseIdentifier: ExtendedCatalogItemCell.reuseIdentifier,
                                     for: indexPath) as? ExtendedCatalogItemCell
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

            let view = collection
                .dequeueReusableSupplementaryView(ofKind: "Header",
                                                  withReuseIdentifier: ExtendedCatalogHeaderView.reuseIdentifier,
                                                  for: indexPath) as? ExtendedCatalogHeaderView

            view?.bind(viewModel: headerViewModel)

            return view
        }
        return dataSource
    }

    func setupCollectionView() {
        collectionView.register(UINib(nibName: "ExtendedCatalogItemCell", bundle: .main),
                                forCellWithReuseIdentifier: ExtendedCatalogItemCell.reuseIdentifier)

        collectionView.register(UINib(nibName: "ExtendedCatalogHeaderView", bundle: .main),
                                forSupplementaryViewOfKind: "Header",
                                withReuseIdentifier: ExtendedCatalogHeaderView.reuseIdentifier)

        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout.build(),
                                               animated: false)

        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
}

extension ExtendedCatalogViewController: UICollectionViewDelegate {
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
