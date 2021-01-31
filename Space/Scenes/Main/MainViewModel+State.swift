import Combine
import Foundation

extension MainViewModel {
    struct State: Mutable, Equatable {
        var entries: Loadable<[EPICImage], Never>

        var currentIndex: Int?
        var panningIndex: Int?

        var sharing: Bool
    }
}

extension MainViewModel.State {
    static var initial: MainViewModel.State {
        .init(entries: .reset,
              currentIndex: .none,
              panningIndex: .none,
              sharing: false)
    }

    var isInitial: Bool {
        self == .initial
    }

    var loading: Bool {
        entries.loading
    }

    var currentEntry: EPICImage? {
        currentIndex.flatMap { entries.availableValue?[safe: $0] }
    }

    var panningEntry: EPICImage? {
        panningIndex.flatMap { entries.availableValue?[safe: $0] }
    }

    mutating func receive(entries: [EPICImage]) {
        let previousEntry: EPICImage? = currentEntry

        self.entries.receive(entries)

        currentIndex = previousEntry.map(entries.firstIndex(of:))
            ?? entries.startIndex

        currentIndex.map { prefetch(index: $0) }
    }

    mutating func select(_ entry: EPICImage) {
        currentIndex = entries.availableValue?.firstIndex(of: entry)
        panningIndex = .none

        guard let index = currentIndex else { return }
        prefetch(index: index)
    }

    func prefetch(index: Int, distance: Int = 5) {
        entries
            .availableValue?
            .around(index: index, distance: distance)
            .compactMap { URL(string: $0.previewImageURI) }
            .forEach(dependencies.imageService.prefetch(from:))
    }
}
