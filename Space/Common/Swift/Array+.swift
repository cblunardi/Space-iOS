extension Array {
    static var empty: Self { [] }
}

extension Array {
    func sorted<Property>(by keyPath: KeyPath<Element, Property>) -> Self where Property: Comparable {
        sorted(by: { $0[keyPath: keyPath] < $1[keyPath: keyPath] })
    }

    func min<Property>(by keyPath: KeyPath<Element, Property>) -> Element? where Property: Comparable {
        self.min { $0[keyPath: keyPath] < $1[keyPath: keyPath] }
    }
}

extension Array where Element: Hashable {
    func unique() -> Array<Element> {
        var existence: Set<Element> = .init()

        return filter { element in
            if existence.contains(element) {
                return false
            } else {
                existence.insert(element)
                return true
            }
        }
    }
}

extension Optional {
    mutating func makeAndAppend<Element>(_ element: Element) where Wrapped == Array<Element> {
        self = (self ?? []) + [element]
    }
}
