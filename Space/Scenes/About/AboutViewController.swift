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
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
    }

    func configuredDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { [weak self] (cV, indexPath, item) -> UICollectionViewCell? in
            switch item {
            case let .header(cellVM):
                return self?.configuredAboutHeaderCell(with: cellVM, for: indexPath)
            }
        }

        return dataSource
    }

    private func configuredAboutHeaderCell(with cellViewModel: AboutHeaderViewModel,
                                           for indexPath: IndexPath)
    -> UICollectionViewCell?
    {
        let cell: AboutHeaderCell? = collectionView
            .dequeueReusableCell(withReuseIdentifier: AboutHeaderCell.reuseIdentifier,
                                 for: indexPath) as? AboutHeaderCell
        cell?.bind(viewModel: cellViewModel)
        return cell
    }
}
