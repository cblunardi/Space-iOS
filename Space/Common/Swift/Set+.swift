extension Set {
    mutating func insertIfNotPresent(_ newElement: Element) {
        guard contains(newElement) == false else { return }
        insert(newElement)
    }
}
