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
    final class Unwrap<Upstream, Output>: Publisher where Upstream: Publisher, Upstream.Output == Optional<Output> {

        typealias Failure = Upstream.Failure

        let map: AnyPublisher<Output, Failure>

        init(upstream: Upstream, failure: Failure) {
            map = upstream
                .flatMap { value -> AnyPublisher<Output, Failure> in
                    guard let wrapped = value else {
                        return Fail(error: failure)
                            .eraseToAnyPublisher()
                    }
                    return Just(wrapped)
                        .setFailureType(to: Failure.self)
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            map.receive(subscriber: subscriber)
        }
    }
}
