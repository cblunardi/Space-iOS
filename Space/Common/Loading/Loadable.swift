enum Loadable<Value, Failure> {
    case reset
    case loading
    case loaded(Value)
    case reloading(_ previousValue: Value)
    case failure(Failure)
}

extension Loadable {
    var availableValue: Value? {
        switch self {
        case let .loaded(value),
             let .reloading(value):
            return value
        case .reset, .loading, .failure:
            return nil
        }
    }

    var loading: Bool {
        switch self {
        case .loading, .reloading:
            return true
        case .reset, .loaded, .failure:
            return false
        }
    }

    var loaded: Bool {
        switch self {
        case .loaded:
            return true
        case .reset, .loading, .reloading, .failure:
            return false
        }
    }
}

extension Loadable {
    mutating func receive(_ result: Result<Value, Failure>) where Failure: Error {
        switch result {
        case let .success(value):
            self = .loaded(value)
        case let .failure(failure):
            self = .failure(failure)
        }
    }

    mutating func receive(_ value: Value) {
        self = .loaded(value)
    }

    mutating func receive(_ failure: Failure) {
        self = .failure(failure)
    }

    mutating func reload() {
        guard let value = availableValue else {
            self = .loading
            return
        }
        self = .reloading(value)
    }
}

extension Loadable: Equatable where Value: Equatable, Failure: Equatable {}
