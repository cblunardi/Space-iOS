import Combine

extension Publisher {
    func unwrap<Wrapped>(or failure: Self.Failure)
    -> Publishers.Unwrap<Self, Wrapped>
    where Output == Wrapped?
    {
        .init(upstream: self, failure: failure)
    }
}

extension Publishers {
    final class Unwrap<Upstream, Output>: Publisher where Upstream: Publisher, Upstream.Output == Output? {

        typealias Failure = Upstream.Failure

        let upstream: Upstream
        let failure: Failure

        init(upstream: Upstream, failure: Failure) {
            self.upstream = upstream
            self.failure = failure
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            upstream
                .flatMap { [failure] value -> AnyPublisher<Output, Failure> in
                    guard let wrapped = value else {
                        return Fail(error: failure)
                            .eraseToAnyPublisher()
                    }
                    return Just(wrapped)
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                }
                .receive(subscriber: subscriber)
        }
    }
}
