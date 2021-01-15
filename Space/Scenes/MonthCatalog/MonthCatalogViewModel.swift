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
        let catalog: DateCatalog<EPICImage>
        let focused: DateCatalog<EPICImage>.Month

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

        let year: DateCatalog<EPICImage>.Year = model.catalog
            .years
            .first { $0.months.contains(model.focused) }!

        let selectedDay: DateCatalog<EPICImage>.Day? = model
            .selected
            .map { model.catalog.years[$0.year].months[$0.month].days[$0.day] }

        let selectedIndexPath: IndexPath? = model
            .selected
            .map { IndexPath(row: $0.day, section: $0.month) }

        for month in year.months {
            guard let section = month.localizedDate.map(Section.init(date:)) else { continue }

            let entries: [CatalogDayViewModel] = month.days
                .map { CatalogDayViewModel(model: $0, selected: $0 == selectedDay) }

            snapshot.appendSections([section])
            snapshot.appendItems(entries, toSection: section)
        }

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
