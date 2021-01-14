import Combine
import UIKit

protocol MonthCatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class MonthCatalogViewModel: ViewModel {
    private let selectedItemSubject: PassthroughSubject<EPICImage, Never> = .init()

    let coordinator: MonthCatalogCoordinatorProtocol
    let model: Model

    init(model: Model, coordinator: MonthCatalogCoordinatorProtocol) {
        self.model = model
        self.coordinator = coordinator
    }
}

extension MonthCatalogViewModel {
    struct Model {
        let catalog: DateCatalog<EPICImage>.Month
        let selected: DateCatalog<EPICImage>.Route?
    }

    struct Section: Hashable {
        let date: String
    }
}

extension MonthCatalogViewModel {
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, CatalogDayViewModel>

    struct SnapshotAdapter {
        let snapshot: SnapshotType
        let selectedIndex: IndexPath?
    }

    var snapshot: SnapshotAdapter {
        snapshotAdapter(from: model)
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

    private func snapshotAdapter(from model: Model) -> SnapshotAdapter {
        var snapshot: SnapshotType = .init()

        let selectedDay: DateCatalog<EPICImage>.Day? = model
            .selected
            .map { model.catalog.days[$0.day] }

        let selectedIndexPath: IndexPath? = model
            .selected
            .map { IndexPath(row: $0.day, section: .zero) }

        let section: Section = .init(date: model.catalog.localizedDate ?? "")
        let items: [CatalogDayViewModel] = model.catalog
            .days
            .map { CatalogDayViewModel(model: $0, selected: $0 == selectedDay) }

        snapshot.appendSections([section])
        snapshot.appendItems(items, toSection: section)

        return .init(snapshot: snapshot, selectedIndex: selectedIndexPath)
    }
}

extension MonthCatalogViewModel: MonthCatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> {
        selectedItemSubject.eraseToAnyPublisher()
    }

    func didSelect(item: CatalogDayViewModel) {
        guard let entry = item.model.models.first else { return }
        coordinator.close()
        selectedItemSubject.send(entry)
    }
}
