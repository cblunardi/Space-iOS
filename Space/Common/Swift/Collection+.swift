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
        var groups: [(Key, [Element])] = .init()

        forEach { element in
            let key = keyer(element)
            guard let index = indexes[key] else {
                groups.append((key, [element]))
                indexes[key] = groups.indices.last
                return
            }
            groups[index].1.append(element)
        }

        return groups
    }
}
