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
        title = viewModel.title

        dataSource.apply(viewModel.snapshot)
    }
}

private extension AboutViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<AboutViewModel.Section, AboutViewModel.Item>

    func configure() {
        setupCloseButton()

        collectionView.register(R.nib.aboutHeaderCell)

        collectionView.dataSource = dataSource
        collectionView.delegate = self

        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout
            .list(using: .init(appearance: .insetGrouped))
    }

    func configuredDataSource() -> DataSource {
        let optionRegistration = makeOptionRegistration()
        let footerRegistration = makeFooterRegistration()

        let dataSource: DataSource = .init(collectionView: collectionView) { (collectionView, indexPath, item) in
            switch item {
            case .header:
                return collectionView
                    .dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.aboutHeaderCell,
                                         for: indexPath)
            case let .option(option):
                return collectionView
                    .dequeueConfiguredReusableCell(using: optionRegistration,
                                                   for: indexPath,
                                                   item: option)
            case let .footer(footer):
                return collectionView
                    .dequeueConfiguredReusableCell(using: footerRegistration,
                                                   for: indexPath,
                                                   item: footer)
            }
        }

        return dataSource
    }

    private func makeOptionRegistration()
    -> UICollectionView.CellRegistration<UICollectionViewListCell, AboutViewModel.Option>
    {
        .init { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = Colors.palette2
            content.text = item.title
            content.image = item.image
            cell.contentConfiguration = content
        }
    }

    private func makeFooterRegistration()
    -> UICollectionView.CellRegistration<UICollectionViewListCell, AboutViewModel.Footer>
    {
        .init { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = Colors.palette2
            content.text = item.text
            content.image = item.image
            cell.contentConfiguration = content
        }
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
