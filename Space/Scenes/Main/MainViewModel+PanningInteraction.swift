import Combine
import Foundation

extension MainViewModel {
    func didRecognize(relativeTranslation: Double) {
        assert((-1...1).contains(relativeTranslation))

        guard
            let currentImageDate = state.value.currentEntry?.swiftDate,
            let targetDate = currentImageDate.advanced(by: relativeTranslation * 24.0),
            let bestEntryMatch = state.value.catalogs.availableValue?.entryClosest(to: targetDate)
        else {
            return
        }

        guard state.value.panningEntry != bestEntryMatch else { return }
        state.value.panningEntry = bestEntryMatch

        loadNextCatalogsIfNeeded()
    }

    func didFinishPanning() {
        state.value.currentEntry = state.value.panningEntry
        state.value.panningEntry = .none
    }
}

private extension MainViewModel {
    func loadNextCatalogsIfNeeded() {
        let dates = state.value.dates.availableValue
        guard
            state.value.catalogs.loading == false,
            let catalogs = state.value.catalogs.availableValue,
            let entry = state.value.panningEntry ?? state.value.currentEntry,
            let catalogIndex = catalogs.firstIndex(containing: entry),
            let catalog = catalogs[safe: catalogIndex],
            let dateIndex = dates?.firstIndex(where: { $0.date == catalog.date }),
            let nextDate = dates?[safe: dateIndex + 1] ?? dates?[safe: dateIndex - 1],
            catalogs.contains(where: { $0.date == nextDate.date }) == false
        else {
            return
        }

        state.value.catalogs.reload()

        dependencies
            .epicService
            .getCatalog(from: nextDate)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.state.value.receive(catalog: .init(date: nextDate, images: $0)) })
            .store(in: &subscriptions)
    }
}

private extension Date {
    func advanced(by hoursAmount: Double) -> Date? {
        let calendar: Calendar = .init(identifier: .iso8601)

        let hours: Int = Int(hoursAmount.truncatingRemainder(dividingBy: 24.0))
        let absMinutes: Double = hoursAmount * 60.0
        let minutes: Int = Int(absMinutes.truncatingRemainder(dividingBy: 60.0))
        let absSeconds: Double = hoursAmount * 60.0 * 60.0
        let seconds: Int = Int(absSeconds.truncatingRemainder(dividingBy: 60.0))

        let dateComponents: DateComponents = .init(calendar: calendar,
                                                   hour: hours,
                                                   minute: minutes,
                                                   second: seconds)

        return calendar.date(byAdding: dateComponents, to: self)
    }
}

private extension Array where Element == EPICImageCatalog {
    func entryClosest(to date: Date) -> EPICImageEntry? {
        lazy
            .flatMap(\.images)
            .compactMap { entry in
                entry.swiftDate.map { entryDate in
                    (entry, abs(entryDate.timeIntervalSince(date)))
                }
            }
            .min(by: { $0.1 < $1.1 })?.0
    }

    func firstIndex(containing entry: EPICImageEntry) -> Index? {
        firstIndex { $0.images.contains(entry) }
    }
}
