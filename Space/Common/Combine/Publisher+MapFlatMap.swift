import Combine

extension Publisher {
    /// Maps an optional `Output` into an optional mapped `Output`
    func mapFlatMap<Value, MappedValue>(_ transform: @escaping (Value?) -> MappedValue?)
    -> Publishers.Map<Self, MappedValue?> where Output == Value?
    {
        map { $0.flatMap(transform) }
    }
}
