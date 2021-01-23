import Combine
import Foundation

extension MainViewModel {
    func didRecognize(relativeTranslation: Double) {
        assert((-1...1).contains(relativeTranslation))

        let state = self.state.value

        guard
            let index = state.currentIndex ?? state.panningIndex,
            let currentImageDate = state.currentEntry?.date,
            let targetDate = currentImageDate.advanced(by: relativeTranslation * 12),
            let bestMatchIndex = state.entries.availableValue?.closestIndex(to: targetDate,
                                                                            indexHint: index)
        else {
            return
        }

        guard state.panningIndex != bestMatchIndex else { return }
        self.state.value.panningIndex = bestMatchIndex

        self.state.value.prefetch(index: bestMatchIndex, distance: 7)
    }

    func didFinishPanning() {
        state.value.currentIndex = state.value.panningIndex
        state.value.panningIndex = .none
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
    private var searchDistance: Int { 12 }

    func closestIndex(to date: Date, indexHint: Index) -> Int? {
        around(index: indexHint, distance: searchDistance)
            .enumerated()
            .min(by: { nearest($0.element, $1.element, to: date) })
            .map { Swift.max(startIndex, indexHint - searchDistance) + $0.offset }
    }

    private func nearest(_ lhs: EPICImage, _ rhs: EPICImage, to date: Date) -> Bool {
        abs(lhs.date.timeIntervalSince(date)) < abs(rhs.date.timeIntervalSince(date))
    }
}
