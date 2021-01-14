extension DateCatalog {
    struct Route {
        let year: Int
        let month: Int
        let day: Int
        let entry: Int
    }

    subscript(route: DateCatalog.Route) -> DateCatalog.Year {
        years[route.year]
    }

    func route(of model: Model) -> Route? {
        years
            .lazy
            .enumerated()
            .compactMap { $0.element.route(of: model, year: $0.offset) }
            .first
    }
}

extension DateCatalog.Year {
    subscript(route: DateCatalog.Route) -> DateCatalog.Month {
        months[route.month]
    }

    func route(of model: Model, year: Int) -> DateCatalog.Route? {
        months
            .lazy
            .enumerated()
            .compactMap { $0.element.route(of: model, year: year, month: $0.offset) }
            .first
    }
}

extension DateCatalog.Month {
    subscript(route: DateCatalog.Route) -> DateCatalog.Day {
        days[route.day]
    }

    func route(of model: Model, year: Int, month: Int) -> DateCatalog.Route? {
        days
            .lazy
            .enumerated()
            .compactMap { $0.element.route(of: model, year: year, month: month, day: $0.offset) }
            .first
    }
}

extension DateCatalog.Day {
    subscript(route: DateCatalog.Route) -> DateCatalog.Entry {
        entries[route.entry]
    }

    func route(of model: Model, year: Int, month: Int, day: Int) -> DateCatalog.Route? {
        entries
            .lazy
            .firstIndex(where: { $0.model == model })
            .map { DateCatalog.Route(year: year, month: month, day: day, entry: $0) }
    }
}
