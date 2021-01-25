import Combine
import UIKit

final class AboutViewController: UIViewController, StoryboardLoadable, ViewModelOwner {
    var viewModel: AboutViewModel!

    @IBOutlet private var collectionView: UICollectionView!

    private lazy var dataSource: DataSource = configuredDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bind(viewModel: viewModel)
    }

    func bind(viewModel: AboutViewModel) {
        dataSource.apply(viewModel.snapshot)
    }
}

private extension AboutViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<AboutViewModel.Section, AboutViewModel.Item>

    func configure() {
        collectionView.register(UINib(nibName: "AboutHeaderCell",
                                      bundle: .main),
                                forCellWithReuseIdentifier: AboutHeaderCell.reuseIdentifier)

        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
    }

    func configuredDataSource() -> DataSource {
        let optionRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, AboutViewModel.Option> = .init { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
        }

        let dataSource: DataSource = .init(collectionView: collectionView) { (cV, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case .header:
                return cV
                    .dequeueReusableCell(withReuseIdentifier: AboutHeaderCell.reuseIdentifier,
                                         for: indexPath)
            case let .option(cellVM):
                return cV
                    .dequeueConfiguredReusableCell(using: optionRegistration,
                                                   for: indexPath,
                                                   item: cellVM)
            }
        }

        return dataSource
    }
}

extension AboutViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = dataSource.snapshot()
        guard
            let section: AboutViewModel.Section = snapshot.sectionIdentifiers[safe: indexPath.section],
            let item: AboutViewModel.Item = snapshot.itemIdentifiers(inSection: section)[safe: indexPath.item]
        else {
            return
        }

        viewModel.didSelect(item)

        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
