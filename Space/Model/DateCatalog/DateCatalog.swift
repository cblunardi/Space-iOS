import Foundation

struct DateCatalog<Model> where Model: Hashable {
    let years: [Year]
}

extension DateCatalog {
    struct Year: Hashable {
        let dateComponents: DateComponents
        let date: Date

        let months: [Month]

        func hash(into hasher: inout Hasher) {
            dateComponents.hash(into: &hasher)
        }
    }
}

extension DateCatalog {
    struct Month: Hashable {
        let dateComponents: DateComponents
        let date: Date

        let days: [Day]

        func hash(into hasher: inout Hasher) {
            dateComponents.hash(into: &hasher)
        }
    }
}

extension DateCatalog {
    struct Day: Hashable {
        let dateComponents: DateComponents
        let date: Date

        let entries: [Entry]

        func hash(into hasher: inout Hasher) {
            dateComponents.hash(into: &hasher)
        }
    }
}

extension DateCatalog {
    struct Entry: Hashable {
        let dateComponents: DateComponents
        let date: Date

        let model: Model

        func hash(into hasher: inout Hasher) {
            dateComponents.hash(into: &hasher)
        }
    }
}
