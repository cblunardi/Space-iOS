import Combine
import Foundation

extension MainViewModel {
    struct State: Mutable, Equatable {
        var dates: Loadable<[EPICDateEntry], Never>
        var catalogs: Loadable<[EPICImageCatalog], Never>

        var panningEntry: EPICImageEntry?
        var currentEntry: EPICImageEntry?
    }
}

extension MainViewModel.State {
    static var initial: MainViewModel.State {
        .init(dates: .reset, catalogs: .reset, currentEntry: .none)
    }

    var isInitial: Bool {
        self == .initial
    }

    var isLoading: Bool {
        dates.loading || catalogs.loading
    }

    mutating func receive(dates: [EPICDateEntry]) {
        self.dates.receive(dates)
    }

    mutating func receive(catalog: EPICImageCatalog) {
        let catalogs = (self.catalogs.availableValue ?? []) + [catalog]
        self.catalogs.receive(catalogs.sorted(by: \.date))

        guard currentEntry == .none else { return }
        currentEntry = catalogs.last?.images.last
    }
}
