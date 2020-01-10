import Combine
import UIKit

final class CatalogViewModel: ViewModel {
    private let dateFormatter: DateFormatter = Formatters.dateFormatter

    let entries: [EPICImage]

    init(entries: [EPICImage]) {
        self.entries = entries
    }
}

extension CatalogViewModel {
    struct Section: Hashable {
        let date: String
    }
}

extension CatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, CatalogItemViewModel>
    var snapshot: SnapshotType {
        var snapshot: SnapshotType = .init()

        let groups: [String: [EPICImage]] = entries
            .grouped(by: { dateFormatter.string(from: $0.date) })

        for (key, element) in groups {
            snapshot.appendSections([Section(date: key)])
            snapshot.appendItems(element.map { CatalogItemViewModel(entry: $0) })
        }

        return snapshot
    }
}
