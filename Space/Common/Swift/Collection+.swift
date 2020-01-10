extension Collection {
    func grouped<Key>(by keyer: (Element) -> Key) -> [Key: [Element]] where Key: Hashable {
        var groups: [Key: [Element]] = .init()

        forEach { element in
            let key = keyer(element)
            groups[key].makeAndAppend(element)
        }

        return groups
    }
}
