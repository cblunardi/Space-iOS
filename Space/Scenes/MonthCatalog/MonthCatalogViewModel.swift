import Combine
import UIKit

protocol MonthCatalogViewModelInterface {
    var selectedItem: AnyPublisher<EPICImage, Never> { get }
}

final class MonthCatalogViewModel: ViewModel {
    private let yearFormatter: DateFormatter = Formatters.yearFormatter
    private let monthFormatter: DateFormatter = Formatters.longMonthFormatter
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

    var snapshot: AnyPublisher<SnapshotAdapter, Never> {
        Future(execute: { [unowned self] in self.snapshotAdapter(from: self.model) },
               on: DispatchQueue.diffing)
            .eraseToAnyPublisher()
    }

    var title: String? {
        yearFormatter.string(from: model.focusedYear.date)
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
            .map { IndexPath(row: model.focused.daysRange.median() ?? .zero, section: $0) }

        for month in model.focusedYear.months {
            let section = Section(date: monthFormatter.string(from: month.date))

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
        guard let entry = item.model.calendarDay.day?.models.median() else {
            return
        }

        coordinator.close()
        selectedItemSubject.send(entry)
    }
}

private extension MonthCatalogViewModel {
    func items(for month: DateCatalog<EPICImage>.Month,
               selectedDay: DateCatalog<EPICImage>.Day?)
    -> [CatalogDayViewModel]
    {
        month.calendarDays(selectedDay: selectedDay)
            .map { .init(model: .init(month: month, calendarDay: $0)) }
    }
}
