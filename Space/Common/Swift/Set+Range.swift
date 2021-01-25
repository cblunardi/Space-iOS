extension Set where Element: Hashable & Comparable & Strideable, Element.Stride == Int {
    init(ranges: [Range<Element>]) {
        var elements: Self = .init()

        for range in ranges {
            for element in range {
                elements.insertIfNotPresent(element)
            }
        }

        self = elements
    }
}


