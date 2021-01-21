extension Collection {
    func grouped<Key>(by keyer: (Element) -> Key) -> [Key: [Element]] where Key: Hashable {
        var groups: [Key: [Element]] = .init()

        forEach { element in
            let key = keyer(element)
            groups[key].makeAndAppend(element)
        }

        return groups
    }

    func stablyGrouped<Key>(by keyer: (Element) -> Key) -> [(Key, [Element])] where Key: Hashable {
        var indexes: [Key: Int] = .init()
        var groups: [(key: Key, elements: [Element])] = .init()

        forEach { element in
            let key = keyer(element)
            guard let index = indexes[key] else {
                groups.append((key, [element]))
                indexes[key] = groups.indices.last
                return
            }
            groups[index].elements.append(element)
        }

        return groups
    }
}

extension Collection {
    func slice(safeRange: PartialRangeUpTo<Index>) -> SubSequence {
        let upperBound: Index = Swift.min(endIndex, safeRange.upperBound)

        return self[startIndex..<upperBound]
    }
}

extension Collection where Index == Int {
    func slice(safeRange: Range<Index>) -> SubSequence {
        let lowerBound: Index = Swift.max(startIndex, safeRange.lowerBound)
        let upperBound: Index = Swift.min(endIndex - 1, safeRange.upperBound)

        return self[lowerBound..<upperBound]
    }

    func slice(safeRange: PartialRangeFrom<Index>) -> SubSequence {
        let lowerBound: Index = Swift.max(startIndex, safeRange.lowerBound)

        return self[lowerBound..<endIndex]
    }

    func slice(safeRange: ClosedRange<Index>) -> SubSequence {
        let lowerBound: Index = Swift.max(startIndex, safeRange.lowerBound)
        let upperBound: Index = Swift.min(endIndex - 1, safeRange.upperBound)

        return self[lowerBound...upperBound]
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

extension Collection where Index == Int {
    func median(roundingRule: FloatingPointRoundingRule = .toNearestOrEven) -> Element? {
        let average: Float = (Float(startIndex) + Float(endIndex)) * 0.5
        let averageIndex: Index = Int(average.rounded(roundingRule))
        return self[safe: averageIndex]
    }
}

extension Collection where Index == Int {
    func around(index: Index, distance: Index) -> SubSequence {
        slice(safeRange: (index - distance) ... (index + distance))
    }
}
