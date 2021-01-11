import Combine
import UIKit

final class CatalogViewModel: ViewModel {
    private let dateFormatter: DateFormatter = Formatters.dateFormatter

    let entries: [EPICImage]

    init(model: Model) {
        entries = model
    }
}

extension CatalogViewModel {
    typealias Model = [EPICImage]

    struct Section: Hashable {
        let date: String
    }
}

extension CatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, CatalogItemViewModel>
    var snapshot: SnapshotType {
        var snapshot: SnapshotType = .init()

        let groups: [(String, [EPICImage])] = entries
            .stablyGrouped(by: { dateFormatter.string(from: $0.date) })
            .reversed()

        for (key, element) in groups {
            snapshot.appendSections([Section(date: key)])
            snapshot.appendItems(element.map { CatalogItemViewModel(entry: $0) })
        }

        return snapshot
    }

    func supplementaryViewViewModel(of kind: String, for indexPath: IndexPath) -> CatalogHeaderViewModel? {
        snapshot.sectionIdentifiers[safe: indexPath.section]
            .map { CatalogHeaderViewModel(model: $0) }
    }
}
