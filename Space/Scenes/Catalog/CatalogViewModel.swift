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

    struct SnapshotAdapter {
        let snapshot: SnapshotType
        let selectedIndex: IndexPath?
    }

    var snapshot: AnyPublisher<SnapshotAdapter, Never> {
        Future { [weak self, model] promise in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let self = self else { return }
                promise(.success(self.snapshotAdapter(from: model)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }

    func supplementaryViewViewModel(of kind: String,
                                    for indexPath: IndexPath,
                                    using snapshot: SnapshotType)
    -> CatalogHeaderViewModel?
    {
        snapshot
            .sectionIdentifiers[safe: indexPath.section]
            .map(CatalogHeaderViewModel.init(model:))
    }

    private func snapshotAdapter(from model: Model) -> SnapshotAdapter {
        var snapshot: SnapshotType = .init()

        let groups: [(Section, [EPICImage])] = model
            .entries
            .stablyGrouped(by: { Section(datetime: $0.date) })
            .reversed()

        for (key, element) in groups {
            snapshot.appendSections([key])
            snapshot.appendItems(element.map { CatalogItemViewModel(entry: $0) })
        }

        let selectedIndex: IndexPath? = model.initialEntry
            .flatMap(groups.firstIndexPath(of:))

        return .init(snapshot: snapshot, selectedIndex: selectedIndex)
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

private extension CatalogViewModel.Section {
    init(datetime: Date) {
        date = Formatters.dateFormatter.string(from: datetime)
    }
}

private extension Array where Element == (CatalogViewModel.Section, [EPICImage]) {
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
