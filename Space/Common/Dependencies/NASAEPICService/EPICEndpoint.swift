import Foundation

enum EPICEndpoint {
    case getAvailableDates(type: CatalogType = .natural)
    case getRecentCatalog(type: CatalogType = .natural)
    case getCatalog(type: CatalogType = .natural, entry: EPICDateEntry)
    case getImage(type: CatalogType = .natural, entry: EPICImageEntry)
}

extension EPICEndpoint {
    enum CatalogType {
        case natural, enhanced
    }

    var catalogType: CatalogType {
        switch self {
        case let .getAvailableDates(type: type),
             let .getRecentCatalog(type: type),
             let .getCatalog(type: type, entry: _),
             let .getImage(type: type, entry: _):
            return type
        }
    }
}

extension EPICEndpoint {
    var url: URL? {
        var path: [String] = ["EPIC"]

        switch self {
        case .getAvailableDates, .getCatalog, .getRecentCatalog:
            path.append("api")
        case .getImage:
            path.append("archive")
        }

        switch catalogType {
        case .natural:
            path.append("natural")
        case .enhanced:
            path.append("enhanced")
        }

        switch self {
        case .getAvailableDates:
            path.append("all")
        case .getRecentCatalog:
            path.append("images")
        case let .getCatalog(type: _, entry: entry):
            path.append(entry.date)
        case let .getImage(type: _, entry: entry):
            guard let dateParameters = entry.asDateParameters else { return nil }
            path.append(contentsOf: dateParameters)
            path.append("png")
            path.append(entry.image + ".png")
        }

        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "api.nasa.gov"
        components.path = path.joined(separator: "/")

        return components.url
    }
}

private extension EPICImageEntry {
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "EST")
        return formatter
    }

    private var calendar: Calendar {
        Calendar(identifier: .iso8601)
    }

    var asDateParameters: [String]? {
        guard let date = dateFormatter.date(from: date) else {
            return nil
        }

        let components: [Calendar.Component] = [.year, .month, .day]

        return components.map { calendar.component($0, from: date).description }
    }
}
