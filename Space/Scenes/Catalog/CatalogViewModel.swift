import Combine
import UIKit

protocol CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class CatalogViewModel: ViewModel {
    private let workingQueue: DispatchQueue = .global(qos: .userInitiated)
    private let dateFormatter: DateFormatter = Formatters.dateFormatter

    private let stateSubject: CurrentValueSubject<State, Never> = .init(.init())
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    private var subscriptions: Set<AnyCancellable> = .init()

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

    struct State: Mutable {
        var catalog: Loadable<DateCatalog<EPICImage>, Never> = .reset
    }
}

extension CatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, CatalogMonthViewModel>

    struct SnapshotAdapter {
        let snapshot: SnapshotType
        let selectedIndex: IndexPath?
    }

    var snapshot: AnyPublisher<SnapshotAdapter, Never> {
        stateSubject
            .receive(on: workingQueue)
            .compactMap { $0.catalog.availableValue }
            .compactMap { [weak self] in self?.snapshotAdapter(from: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func load() {
        guard stateSubject.value.catalog.loading == false else { return }

        let entries = model.entries

        stateSubject.value.catalog.reload()

        Future(execute: DateCatalog(with: entries), on: workingQueue)
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.stateSubject.value.catalog.receive($0) }
            .store(in: &subscriptions)
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

    private func snapshotAdapter(from catalog: DateCatalog<EPICImage>) -> SnapshotAdapter {
        var snapshot: SnapshotType = .init()

        let selectedIndex: IndexPath? = model
            .initialEntry
            .flatMap(catalog.years.firstIndexPath(of:))

        let selectedDay: DateCatalog<EPICImage>.Day?
        if let selectedIndex = selectedIndex, let model = model.initialEntry {
            selectedDay = catalog
                .years[safe: selectedIndex.section]?
                .months[safe: selectedIndex.item]?
                .days
                .first(where: { $0.entries.lazy.map(\.model).contains(model) })
        } else {
            selectedDay = nil
        }

        for year in catalog.years {
            guard let yearDate = year.date else { continue }

            let items: [CatalogMonthViewModel] = year.months
                .map { .init(month: $0, selectedDay: selectedDay) }

            snapshot.appendSections([Section(datetime: yearDate)])
            snapshot.appendItems(items)
        }

        return .init(snapshot: snapshot, selectedIndex: selectedIndex)
    }
}

extension CatalogViewModel: CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    func didSelect(item: CatalogMonthViewModel) {
        coordinator
            .showExtendedCatalog(model: .init(entries: model.entries,
                                              initialEntry: .none))
            .selectedItem
            .sink(receiveValue: { [weak self] in self?.selectedItemSubject.send($0) })
            .store(in: &subscriptions)
    }
}

private extension CatalogViewModel.Section {
    init(datetime: Date) {
        date = Formatters.yearFormatter.string(from: datetime)
    }
}

private extension Array where Element == DateCatalog<EPICImage>.Year {
    func firstIndexPath(of entry: EPICImage) -> IndexPath? {
        lazy
            .enumerated()
            .compactMap { (offset, element) -> IndexPath? in
                element
                    .months
                    .firstIndex(where: {
                        $0.days.lazy.flatMap(\.models).contains(entry)
                    })
                    .map { IndexPath(item: $0, section: offset) }
            }.first
    }
}
