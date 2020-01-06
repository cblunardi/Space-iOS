import Combine
import CoreGraphics
import Foundation

extension MainViewModel {
    func didRecognize(panning: CGFloat) {
        assert((-1...1).contains(panning))

        guard let currentImageDate = state.value.currentEntry?.swiftDate else { return }

        let calendar: Calendar = .init(identifier: .iso8601)

        let absHours: CGFloat = panning * 24.0
        let hours: Int = Int(absHours.truncatingRemainder(dividingBy: 24.0))
        let absMinutes: CGFloat = panning * 24.0 * 60.0
        let minutes: Int = Int(absMinutes.truncatingRemainder(dividingBy: 60.0))
        let absSeconds: CGFloat = panning * 24.0 * 60.0 * 60.0
        let seconds: Int = Int(absSeconds.truncatingRemainder(dividingBy: 60.0))

        let dateComponents: DateComponents = .init(calendar: calendar,
                                                   hour: hours,
                                                   minute: minutes,
                                                   second: seconds)

        guard let targetDate: Date = calendar.date(byAdding: dateComponents, to: currentImageDate) else {
            return
        }

        guard let entries = state.value.catalogs.availableValue?.lazy.flatMap(\.images) else {
            return
        }

        let entriesWithTargetDistance = entries
            .compactMap { entry in
                entry.swiftDate.map { date in
                    (entry, abs(date.timeIntervalSince(targetDate)))
                }
            }

        guard let closestEntry = entriesWithTargetDistance.min(by: { $0.1 < $1.1 })?.0 else {
            return
        }

        guard state.value.panningEntry != closestEntry else { return }
        state.value.panningEntry = closestEntry
    }

    func didFinishPanning() {
        state.value.currentEntry = state.value.panningEntry
    }
}
