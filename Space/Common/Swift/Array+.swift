extension Array {
    static var empty: Self { [] }
}

extension Array {
    func sorted<Property>(by keyPath: KeyPath<Element, Property>) -> Self where Property: Comparable {
        sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }
}
