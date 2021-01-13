import Combine
import UIKit

protocol ExtendedCatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class ExtendedCatalogViewModel: ViewModel {
    private let dateFormatter: DateFormatter = Formatters.dateFormatter

    private let groupsSubject: AnyPublisher<Groups, Never>
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    let coordinator: ExtendedCatalogCoordinatorProtocol
    let model: Model

    init(model: Model, coordinator: ExtendedCatalogCoordinatorProtocol) {
        self.model = model
        self.coordinator = coordinator

        groupsSubject = Self.makeGroupsFuture(model: model)
    }
}

extension ExtendedCatalogViewModel {
    struct Model {
        let entries: [EPICImage]
        let initialEntry: EPICImage?
    }

    struct Section: Hashable {
        let date: String
    }
}

extension ExtendedCatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, ExtendedCatalogItemViewModel>

    struct SnapshotAdapter {
        let snapshot: SnapshotType
        let selectedIndex: IndexPath?
    }

    var snapshot: AnyPublisher<SnapshotAdapter, Never> {
        groupsSubject
            .compactMap { [weak self] in self?.snapshotAdapter(from: $0) }
            .eraseToAnyPublisher()
    }

    func supplementaryViewViewModel(of kind: String,
                                    for indexPath: IndexPath,
                                    using snapshot: SnapshotType)
    -> ExtendedCatalogHeaderViewModel?
    {
        snapshot
            .sectionIdentifiers[safe: indexPath.section]
            .map(ExtendedCatalogHeaderViewModel.init(model:))
    }

    private func snapshotAdapter(from groups: Groups) -> SnapshotAdapter {
        var snapshot: SnapshotType = .init()

        for (key, element) in groups {
            snapshot.appendSections([key])
            snapshot.appendItems(element.map { ExtendedCatalogItemViewModel(entry: $0) })
        }

        let selectedIndex: IndexPath? = model.initialEntry
            .flatMap(groups.firstIndexPath(of:))

        return .init(snapshot: snapshot, selectedIndex: selectedIndex)
    }
}

private extension ExtendedCatalogViewModel {
    typealias Groups = [(Section, [EPICImage])]

    static func makeGroupsFuture(model: Model) -> AnyPublisher<Groups, Never> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                let groups = model
                    .entries
                    .stablyGrouped(by: { Section(datetime: $0.date) })
                    .reversed()
                promise(.success(Array(groups)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}

extension ExtendedCatalogViewModel: ExtendedCatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    func didSelect(item: ExtendedCatalogItemViewModel) {
        coordinator.close()
        selectedItemSubject.send(item.entry)
    }
}

private extension ExtendedCatalogViewModel.Section {
    init(datetime: Date) {
        date = Formatters.dateFormatter.string(from: datetime)
    }
}

private extension Array where Element == (ExtendedCatalogViewModel.Section, [EPICImage]) {
    func firstIndexPath(of entry: EPICImage) -> IndexPath? {
        lazy
            .enumerated()
            .compactMap { (offset, element) -> IndexPath? in
                element.1
                    .firstIndex(of: entry)
                    .map { IndexPath(item: $0, section: offset) }
            }.first
    }
}
