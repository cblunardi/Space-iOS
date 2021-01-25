import Foundation

extension DateCatalog {
    var models: [Model] {
        years.flatMap(\.models)
    }
}

extension DateCatalog.Year {
    var models: [Model] {
        months.flatMap(\.models)
    }
}

extension DateCatalog.Month {
    var models: [Model] {
        days.flatMap(\.models)
    }
}

extension DateCatalog.Day {
    var models: [Model] {
        entries.map(\.model)
    }
}
