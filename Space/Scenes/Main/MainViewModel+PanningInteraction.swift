import Combine
import Foundation

extension MainViewModel {
    func didRecognize(relativeTranslation: Double) {
        assert((-1...1).contains(relativeTranslation))

        guard
            let currentImageDate = state.value.currentEntry?.date,
            let targetDate = currentImageDate.advanced(by: relativeTranslation * 24.0),
            let bestEntryMatch = state.value.entries.availableValue?.entryClosest(to: targetDate)
        else {
            return
        }

        guard state.value.panningEntry != bestEntryMatch else { return }
        state.value.panningEntry = bestEntryMatch


        guard
            let entries = state.value.entries.availableValue,
            let index = entries.firstIndex(of: bestEntryMatch) else {
            return
        }

        entries.around(index: index, distance: 10)
            .compactMap { URL(string: $0.uri) }
            .forEach(dependencies.imageService.prefetch(from:))
    }

    func didFinishPanning() {
        state.value.currentEntry = state.value.panningEntry
        state.value.panningEntry = .none
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

private extension Array where Element == EPICImage {
    func entryClosest(to date: Date) -> EPICImage? {
        self.min(by: {
            abs($0.date.timeIntervalSince(date))
                < abs($1.date.timeIntervalSince(date))
        })
    }
}
