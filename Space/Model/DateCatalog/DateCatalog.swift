import Foundation

struct DateCatalog<Model> where Model: Hashable {
    let years: [Year]
}

extension DateCatalog {
    struct Year: Hashable {
        let components: DateComponents
        let months: [Month]
    }
}

extension DateCatalog {
    struct Month: Hashable {
        let components: DateComponents
        let days: [Day]
    }
}

extension DateCatalog {
    struct Day: Hashable {
        let components: DateComponents
        let entries: [Entry]
    }
}

extension DateCatalog {
    struct Entry: Hashable {
        let date: Date
        let model: Model
    }
}
