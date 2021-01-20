import Combine

extension Publisher {
    func tuple<T>(with value: T) -> Publishers.Map<Self, (Output, T)> {
        map { ($0, value) }
    }

    func flatMapTuple<P, M>(_ transform: @escaping (Output) -> P)
    -> Publishers.FlatMap<Publishers.Map<P, (M, Output)>, Self>
    where P: Publisher, P.Output == M, P.Failure == Failure
    {
        flatMap { output in
            transform(output).tuple(with: output)
        }
    }
}
