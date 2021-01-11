import Combine
import UIKit

protocol CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class CatalogViewModel: ViewModel {
    private let dateFormatter: DateFormatter = Formatters.dateFormatter
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    let coordinator: CatalogCoordinatorProtocol

    let entries: [EPICImage]

    init(model: Model, coordinator: CatalogCoordinatorProtocol) {
        entries = model
        self.coordinator = coordinator
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

extension CatalogViewModel: CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    func didSelect(item: CatalogItemViewModel) {
        coordinator.close()
        selectedItemSubject.send(item.entry)
    }
}
