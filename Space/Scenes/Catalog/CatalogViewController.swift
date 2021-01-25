import Combine
import Lottie
import UIKit

final class CatalogViewController: UIViewController, ViewModelOwner, StoryboardLoadable {
    typealias DataSource = UICollectionViewDiffableDataSource<CatalogViewModel.Section, CatalogMonthViewModel>

    var viewModel: CatalogViewModel!

    private lazy var dataSource = makeDataSource()
    private var subscriptions: Set<AnyCancellable> = .init()

    @IBOutlet private var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButton()
        setupCollectionView()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: CatalogViewModel) {
        subscriptions.removeAll()

        title = viewModel.title

        viewModel.snapshot
            .sink { [weak self] in
                self?.dataSource.apply($0.snapshot, animatingDifferences: true)

                guard let index = $0.selectedIndex else { return }
                RunLoop.main.perform {
                    self?.collectionView.scrollToItem(at: index,
                                                      at: .centeredVertically,
                                                      animated: false)
                }
            }
            .store(in: &subscriptions)

        viewModel.load()
    }
}

private extension CatalogViewController {
    func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection
                .dequeueReusableCell(withReuseIdentifier: CatalogMonthCell.reuseIdentifier,
                                     for: indexPath) as? CatalogMonthCell
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
                .dequeueReusableSupplementaryView(ofKind: TitleHeaderView.kind,
                                                  withReuseIdentifier: TitleHeaderView.reuseIdentifier,
                                                  for: indexPath) as? TitleHeaderView

            view?.bind(viewModel: headerViewModel)
            view?.setTitle(color: Colors.palette2)

            return view
        }
        return dataSource
    }

    func setupCollectionView() {
        collectionView.register(UINib(nibName: "CatalogMonthCell", bundle: .main),
                                forCellWithReuseIdentifier: CatalogMonthCell.reuseIdentifier)

        collectionView.register(UINib(nibName: "TitleHeaderView", bundle: .main),
                                forSupplementaryViewOfKind: TitleHeaderView.kind,
                                withReuseIdentifier: TitleHeaderView.reuseIdentifier)

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

        let itemSize: NSCollectionLayoutSize =
            .init(widthDimension: .fractionalWidth(1 / 3),
                  heightDimension: .fractionalWidth(2 / 5))

        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize =
            .init(widthDimension: .fractionalWidth(1.0),
                  heightDimension: .fractionalWidth(2 / 5))

        let group: NSCollectionLayoutGroup =
            .horizontal(layoutSize: groupSize,
                        subitems: [item])

        let headerSize: NSCollectionLayoutSize =
            .init(widthDimension: .fractionalWidth(1.0),
                  heightDimension: .estimated(50))

        let header: NSCollectionLayoutBoundarySupplementaryItem =
            .init(layoutSize: headerSize,
                  elementKind: TitleHeaderView.kind,
                  alignment: .topLeading)

        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 3
        section.contentInsets = .init(top: 5, leading: 10, bottom: 5, trailing: 10)

        return .init(section: section)
    }
}
