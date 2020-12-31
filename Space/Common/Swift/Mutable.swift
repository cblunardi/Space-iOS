protocol Mutable {
    func setting<Value>(_ keyPath: WritableKeyPath<Self, Value>, to value: Value) -> Self
}

extension Mutable {
    func setting<Value>(_ keyPath: WritableKeyPath<Self, Value>, to value: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}
