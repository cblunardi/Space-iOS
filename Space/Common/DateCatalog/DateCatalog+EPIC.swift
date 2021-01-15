import Foundation

extension DateCatalog where Model == EPICImage {
    init(with entries: [EPICImage]) {
        let groups: [(DateComponents, [EPICImage])] = entries
            .stablyGrouped(by: { DateComponents.downToYear(from: $0.date) })

        let years: [Year] = groups
            .map { Year(components: $0.0, entries: $0.1) }

        self.init(years: years)
    }
}

extension DateCatalog.Year where Model == EPICImage {
    init(components: DateComponents, entries: [EPICImage]) {
        let groups: [(DateComponents, [EPICImage])] = entries
            .stablyGrouped(by: { DateComponents.downToMonth(from: $0.date) })

        let months: [DateCatalog.Month] = groups
            .map { DateCatalog.Month(components: $0.0, entries: $0.1) }

        self.init(components: components, months: months)
    }
}

extension DateCatalog.Month where Model == EPICImage {
    init(components: DateComponents, entries: [EPICImage]) {
        let groups: [(DateComponents, [EPICImage])] = entries
            .stablyGrouped(by: { DateComponents.downToDay(from: $0.date) })

        let days: [DateCatalog.Day] = groups
            .map { DateCatalog.Day(components: $0.0, entries: $0.1) }

        self.init(components: components, days: days)
    }
}

extension DateCatalog.Day where Model == EPICImage {
    init(components: DateComponents, entries: [EPICImage]) {
        let entries: [DateCatalog.Entry] = entries
            .map { DateCatalog.Entry(entry: $0) }

        self.init(components: components, entries: entries)
    }
}

extension DateCatalog.Entry where Model == EPICImage {
    init(entry: EPICImage) {
        self.init(date: entry.date, model: entry)
    }
}

private extension DateComponents {
    static func downToYear(from date: Date, calendar: Calendar = Formatters.calendar) -> DateComponents {
        .init(calendar: calendar,
              timeZone: .current,
              era: calendar.component(.era, from: date),
              year: calendar.component(.year, from: date),
              month: 1)
    }

    static func downToMonth(from date: Date, calendar: Calendar = Formatters.calendar) -> DateComponents {
        .init(calendar: calendar,
              timeZone: .current,
              era: calendar.component(.era, from: date),
              year: calendar.component(.year, from: date),
              month: calendar.component(.month, from: date),
              day: 1)
    }

    static func downToDay(from date: Date, calendar: Calendar = Formatters.calendar) -> DateComponents {
        .init(calendar: calendar,
              timeZone: .current,
              era: calendar.component(.era, from: date),
              year: calendar.component(.year, from: date),
              month: calendar.component(.month, from: date),
              day: calendar.component(.day, from: date),
              hour: 0)
    }
}
