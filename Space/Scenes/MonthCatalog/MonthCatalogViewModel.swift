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

        var focusedYear: DateCatalog<EPICImage>.Year {
            catalog
                .years
                .first { $0.months.contains(focused) }!
        }
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

    var title: String? {
        model.focusedYear.localizedDate
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
            .map { model.catalog.years[$0.year].months[$0.month].days[$0.day] }

        let selectedIndexPath: IndexPath? = model
            .focusedYear
            .months
            .firstIndex(of: model.focused)
            .map { IndexPath(row: model.focused.dayNumbers?.median() ?? .zero, section: $0) }

        for month in model.focusedYear.months {
            guard
                let section = month.date
                    .flatMap(Formatters.longMonthFormatter.string(from:))
                    .map(Section.init(date:))
            else { continue }

            let entries: [CatalogDayViewModel] = items(for: month,
                                                       selectedDay: selectedDay)

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
        guard let entry = item.model.day?.models.median() else { return }
        coordinator.close()
        selectedItemSubject.send(entry)
    }
}

private extension MonthCatalogViewModel {
    func items(for month: DateCatalog<EPICImage>.Month,
               selectedDay: DateCatalog<EPICImage>.Day?)
    -> [CatalogDayViewModel]
    {
        let firstWeekdayIndex = month.firstWeekdayIndex

        return (0 ..< (7 * 5))
            .map { index in
                let dayNumber = index - firstWeekdayIndex + 1
                let day = month.days.first(where: { $0.components.day == dayNumber })
                return CatalogDayViewModel(model: .init(month: month,
                                                        day: day,
                                                        index: index,
                                                        selectedDay: selectedDay))
            }
    }
}
