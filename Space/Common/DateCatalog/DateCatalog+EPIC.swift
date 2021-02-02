import Foundation

extension DateCatalog where Model == EPICImage {
    init(with entries: [EPICImage]) {
        let entries: [Entry] = entries
            .map(Entry.init(entry:))

        let groups: [(Int, [Entry])] = entries
            .reversed()
            .stablyGrouped(by: { $0.dateComponents.year ?? .zero })

        let years: [Year] = groups
            .reversed()
            .compactMap { Year(entries: $0.1) }

        self.init(years: years)
    }
}

private extension DateCatalog.Year where Model == EPICImage {
    init?(entries: [DateCatalog.Entry]) {
        guard let entry = entries.first else {
            return nil
        }

        let components: DateComponents = entry.dateComponents
            .setting(\.month, to: nil)
            .setting(\.day, to: nil)
            .setting(\.hour, to: nil)
            .setting(\.minute, to: nil)

        guard let date: Date = Formatters.calendar.date(from: components) else {
            return nil
        }

        let groups: [(Int, [DateCatalog.Entry])] = entries
            .stablyGrouped(by: { $0.dateComponents.month ?? .zero })

        let months: [DateCatalog.Month] = groups
            .compactMap { DateCatalog.Month(entries: $0.1) }

        self.init(dateComponents: components,
                  date: date,
                  months: months)
    }
}

private extension DateCatalog.Month where Model == EPICImage {
    init?(entries: [DateCatalog.Entry]) {
        guard let entry = entries.first else {
            return nil
        }

        let components: DateComponents = entry.dateComponents
            .setting(\.day, to: nil)
            .setting(\.hour, to: nil)
            .setting(\.minute, to: nil)

        guard let date: Date = Formatters.calendar.date(from: components) else {
            return nil
        }

        let groups: [(Int, [DateCatalog.Entry])] = entries
            .stablyGrouped(by: { $0.dateComponents.day ?? .zero })

        let days: [DateCatalog.Day] = groups
            .compactMap { DateCatalog.Day(entries: $0.1) }

        self.init(dateComponents: components,
                  date: date,
                  days: days)
    }
}

private extension DateCatalog.Day where Model == EPICImage {
    init?(entries: [DateCatalog.Entry]) {
        guard let entry = entries.first else {
            return nil
        }

        let components: DateComponents = entry.dateComponents
            .setting(\.hour, to: nil)
            .setting(\.minute, to: nil)

        guard let date: Date = Formatters.calendar.date(from: components) else {
            return nil
        }

        self.init(dateComponents: components,
                  date: date,
                  entries: entries)
    }
}

private extension DateCatalog.Entry where Model == EPICImage {
    init(entry: EPICImage) {
        let components: DateComponents = Formatters.calendar
            .dateComponents([.timeZone, .year, .month, .day, .hour, .minute],
                            from: entry.date)
        self.init(dateComponents: components, date: entry.date, model: entry)
    }
}

extension DateComponents: Mutable {}
