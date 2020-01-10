import Combine
import Foundation

extension MainViewModel {
    struct State: Mutable, Equatable {
        var entries: Loadable<[EPICImage], Never>

        var panningEntry: EPICImage?
        var currentEntry: EPICImage?
    }
}

extension MainViewModel.State {
    static var initial: MainViewModel.State {
        .init(entries: .reset, currentEntry: .none)
    }

    var isInitial: Bool {
        self == .initial
    }

    var isLoading: Bool {
        entries.loading
    }

    mutating func receive(entries: [EPICImage]) {
        self.entries.receive(entries.sorted())

        if currentEntry == .none {
            currentEntry = entries.first
        }
    }

}
