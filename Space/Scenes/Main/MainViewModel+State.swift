import Combine
import Foundation

extension MainViewModel {
    struct State: Mutable, Equatable {
        var dates: Loadable<[EPICDateEntry], Never>
        var catalogs: Loadable<[EPICImageCatalog], Never>
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
}
