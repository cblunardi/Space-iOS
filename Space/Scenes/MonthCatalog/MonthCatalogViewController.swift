import Combine
import UIKit

final class MonthCatalogViewController: UIViewController, ViewModelOwner, StoryboardLoadable {
    typealias DataSource = UICollectionViewDiffableDataSource<MonthCatalogViewModel.Section, CatalogDayViewModel>

    private lazy var dataSource = makeDataSource()

    private var subscriptions: Set<AnyCancellable> = .init()

    var viewModel: MonthCatalogViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: MonthCatalogViewModel) {
        subscriptions.removeAll()

        title = viewModel.title

        viewModel.snapshot
            .sink { [weak self] adapter in
                self?.dataSource.apply(adapter.snapshot)

                guard let indexPath = adapter.selectedIndex else { return }
                RunLoop.main.perform {
                    self?.collectionView.scrollToItem(at: indexPath,
                                                      at: .centeredVertically,
                                                      animated: false)
                }
            }.store(in: &subscriptions)
    }
}

private extension MonthCatalogViewController {
    func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection
                .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.catalogDayCell,
                                     for: indexPath)
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
                                                  withReuseIdentifier: TitleHeaderView.reuseIdentifier,
                                                  for: indexPath) as? TitleHeaderView

            view?.bind(viewModel: headerViewModel)

            return view
        }
        return dataSource
    }

    func setupCollectionView() {
        collectionView.register(R.nib.catalogDayCell)

        collectionView.register(UINib(resource: R.nib.titleHeaderView),
                                forSupplementaryViewOfKind: "Header",
                                withReuseIdentifier: TitleHeaderView.reuseIdentifier)

        collectionView.setCollectionViewLayout(UICollectionViewCompositionalLayout.build(),
                                               animated: false)

        collectionView.dataSource = dataSource
        collectionView.delegate = self
    }
}

extension MonthCatalogViewController: UICollectionViewDelegate {
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
        UICollectionViewCompositionalLayout.init { (_, environment) -> NSCollectionLayoutSection? in

            let relativeSize: CGFloat
            switch environment.traitCollection.horizontalSizeClass {
            case .compact, .unspecified:
                relativeSize = 1.0
            case .regular:
                relativeSize = 0.75
            @unknown default:
                relativeSize = 1.0
            }

            let itemSize: NSCollectionLayoutSize =
                .init(widthDimension: .fractionalWidth(1 / 7),
                      heightDimension: .fractionalWidth(1 / 7))
            let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
            item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(relativeSize),
                                                          heightDimension: .estimated(75))
            let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize,
                                                             subitems: [item])
            group.edgeSpacing = .init(leading: .flexible(4.0),
                                      top: nil,
                                      trailing: .flexible(4.0),
                                      bottom: nil)

            let headerSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(relativeSize),
                                                           heightDimension: .estimated(50))
            let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: headerSize,
                                                                            elementKind: "Header",
                                                                            alignment: .topLeading)

            let section: NSCollectionLayoutSection = .init(group: group)
            section.boundarySupplementaryItems = [header]
            section.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

            return section
        }
    }
}
