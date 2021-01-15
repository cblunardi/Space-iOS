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
        dataSource.apply(viewModel.snapshot.snapshot)
    }
}

private extension MonthCatalogViewController {
    func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { collection, indexPath, item in
            let cell = collection
                .dequeueReusableCell(withReuseIdentifier: CatalogDayCell.reuseIdentifier,
                                     for: indexPath) as? CatalogDayCell
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
        collectionView.register(UINib(nibName: "CatalogDayCell", bundle: .main),
                                forCellWithReuseIdentifier: CatalogDayCell.reuseIdentifier)

        collectionView.register(UINib(nibName: "TitleHeaderView", bundle: .main),
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

        let itemSize: NSCollectionLayoutSize = .init(widthDimension: .absolute(35),
                                                     heightDimension: .absolute(35))
        let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)

        let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(35))
        let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize,
                                                         subitems: [item])
        group.interItemSpacing = .flexible(6)

        let headerSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .estimated(50))
        let header: NSCollectionLayoutBoundarySupplementaryItem = .init(layoutSize: headerSize,
                                                                        elementKind: "Header",
                                                                        alignment: .topLeading)

        let section: NSCollectionLayoutSection = .init(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 8
        section.contentInsets = .init(top: 5, leading: 10, bottom: 5, trailing: 10)

        return .init(section: section)
    }
}
