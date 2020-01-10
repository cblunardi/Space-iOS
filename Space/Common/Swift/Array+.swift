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

extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

extension Array {
    func slice(safeRange: Range<Index>) -> ArraySlice<Element> {
        let lowerBound: Int = Swift.max(startIndex, safeRange.lowerBound)
        let upperBound: Int = Swift.min(endIndex, safeRange.upperBound)

        return self[lowerBound..<upperBound]
    }
}

extension Array where Element: Equatable {
    func around(index: Index, distance: Int) -> ArraySlice<Element> {
        slice(safeRange: (index - distance) ..< (index + distance))
    }
}
