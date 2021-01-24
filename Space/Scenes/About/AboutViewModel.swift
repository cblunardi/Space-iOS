import UIKit

final class AboutViewModel: ViewModel {
    private(set) lazy var snapshot: SnapshotType = makeSnapshot()
}

extension AboutViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, Item>

    enum Section {
        case header
    }

    enum Item: Hashable {
        case header(AboutHeaderViewModel)
    }
}

private extension AboutViewModel {
    func makeSnapshot() -> SnapshotType {
        var snapshot: SnapshotType = .init()

        snapshot.appendSections([.header])
        snapshot.appendItems([.header(.init())], toSection: .header)

        return snapshot
    }
}
