import Combine
import UIKit

protocol CatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class CatalogViewModel: ViewModel {
    private let workingQueue: DispatchQueue = .global(qos: .userInitiated)

    private let stateSubject: CurrentValueSubject<Loadable<State, Never>, Never> = .init(.reset)
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    private var subscriptions: Set<AnyCancellable> = .init()

    let coordinator: CatalogCoordinatorProtocol
    let model: Model
    let title: String = "Catalog"

    init(model: Model, coordinator: CatalogCoordinatorProtocol) {
        self.model = model
        self.coordinator = coordinator
    }
}

extension CatalogViewModel {
    struct Model {
        let entries: [EPICImage]
        let selectedEntry: EPICImage?
    }

    struct Section: Hashable {
        let date: String
    }

    struct State: Mutable {
        var catalog: DateCatalog<EPICImage>
        var selectedRoute: DateCatalog<EPICImage>.Route?
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
            .compactMap { $0.availableValue }
            .compactMap { [weak self] in self?.snapshotAdapter(from: $0) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func load() {
        guard stateSubject.value.loading == false else { return }

        stateSubject.value.reload()

        let model = self.model
        Future(execute: State(model: model), on: workingQueue)
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.stateSubject.value.receive($0) }
            .store(in: &subscriptions)
    }

    func supplementaryViewViewModel(of kind: String,
                                    for indexPath: IndexPath,
                                    using snapshot: SnapshotType)
    -> TitleHeaderViewModel?
    {
        snapshot
            .sectionIdentifiers[safe: indexPath.section]
            .map { TitleHeaderViewModel(title: $0.date) }
    }

    private func snapshotAdapter(from state: State) -> SnapshotAdapter {
        var snapshot: SnapshotType = .init()

        let selectedIndex: IndexPath? = state
            .selectedRoute
            .map { IndexPath(item: $0.month, section: $0.year)}

        let selectedDay: DateCatalog<EPICImage>.Day? = state
            .selectedRoute
            .map { state.catalog.years[$0.year].months[$0.month].days[$0.day] }

        for year in state.catalog.years {
            guard let yearDate = year.localizedDate else { continue }

            let items: [CatalogMonthViewModel] = year.months
                .map { .init(month: $0, selectedDay: selectedDay) }

            snapshot.appendSections([Section(date: yearDate)])
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
        guard let state = stateSubject.value.availableValue else { return }

        let model: MonthCatalogViewModel.Model =
            .init(catalog: state.catalog,
                  focused: item.month,
                  selected: state.selectedRoute)

        coordinator
            .showExtendedCatalog(model: model)
            .selectedItem
            .sink(receiveValue: { [weak self] in self?.selectedItemSubject.send($0) })
            .store(in: &subscriptions)
    }
}

private extension CatalogViewModel.State {
    init(model: CatalogViewModel.Model) {
        let catalog: DateCatalog<EPICImage> = .init(with: model.entries)
        self.init(catalog: catalog,
                  selectedRoute: model.selectedEntry.flatMap(catalog.route(of:)))
    }
}
