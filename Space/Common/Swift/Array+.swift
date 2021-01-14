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

    func slice(safeRange: PartialRangeFrom<Index>) -> ArraySlice<Element> {
        let lowerBound: Int = Swift.max(startIndex, safeRange.lowerBound)

        return self[lowerBound..<endIndex]
    }

    func slice(safeRange: PartialRangeUpTo<Index>) -> ArraySlice<Element> {
        let upperBound: Int = Swift.min(endIndex, safeRange.upperBound)

        return self[startIndex..<upperBound]
    }
}

extension Array where Element: Equatable {
    func around(index: Index, distance: Int) -> ArraySlice<Element> {
        slice(safeRange: (index - distance) ..< (index + distance))
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
