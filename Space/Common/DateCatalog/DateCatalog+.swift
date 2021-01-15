import Foundation

protocol DateConvertible {
    var components: DateComponents { get }
    var formatter: DateFormatter { get }

    var date: Date? { get }
    var localizedDate: String? { get }
}

extension DateConvertible {
    var date: Date? {
        components.calendar?.date(from: components)
    }

    var localizedDate: String? {
        date.map(formatter.string(from:))
    }

    func hash(into hasher: inout Hasher) {
        components.hash(into: &hasher)
    }
}

extension DateCatalog {
    var models: [Model] {
        years.flatMap(\.models)
    }
}

extension DateCatalog.Year: DateConvertible {
    var formatter: DateFormatter { Formatters.yearFormatter }

    var models: [Model] {
        months.flatMap(\.models)
    }
}

extension DateCatalog.Month: DateConvertible {
    var formatter: DateFormatter { Formatters.monthFormatter}

    var models: [Model] {
        days.flatMap(\.models)
    }
}

extension DateCatalog.Day: DateConvertible {
    var formatter: DateFormatter { Formatters.dayFormatter }

    var models: [Model] {
        entries.map(\.model)
    }
}
