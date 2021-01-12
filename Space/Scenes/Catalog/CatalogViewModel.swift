import Combine
import UIKit

protocol CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class CatalogViewModel: ViewModel {
    private let dateFormatter: DateFormatter = Formatters.dateFormatter
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    let coordinator: CatalogCoordinatorProtocol

    let model: Model

    init(model: Model, coordinator: CatalogCoordinatorProtocol) {
        self.model = model
        self.coordinator = coordinator
    }
}

extension CatalogViewModel {
    struct Model {
        let entries: [EPICImage]
        let initialEntry: EPICImage?
    }

    struct Section: Hashable {
        let date: String
    }
}

extension CatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, CatalogItemViewModel>
    var snapshot: SnapshotType {
        var snapshot: SnapshotType = .init()

        let groups: [(String, [EPICImage])] = model
            .entries
            .stablyGrouped(by: { dateFormatter.string(from: $0.date) })
            .reversed()

        for (key, element) in groups {
            snapshot.appendSections([Section(date: key)])
            snapshot.appendItems(element.map { CatalogItemViewModel(entry: $0) })
        }

        return snapshot
    }

    var initiallySelectedIndex: IndexPath? {
        model.initialEntry.flatMap(snapshot.index(for:))
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

private extension CatalogViewModel.SnapshotType {
    func index(for entry: EPICImage) -> IndexPath? {
        sectionIdentifiers.lazy.enumerated().compactMap { (sectionIndex, section) -> IndexPath? in
            itemIdentifiers(inSection: section)
                .enumerated()
                .first(where: { $0.element.entry == entry })
                .map { IndexPath(item: $0.offset, section: sectionIndex)}
        }.first
    }
}
