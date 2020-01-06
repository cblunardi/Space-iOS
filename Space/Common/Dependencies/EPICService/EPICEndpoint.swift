import Foundation

enum EPICEndpoint {
    case getAvailableDates(catalogType: CatalogType = .natural)
    case getRecentCatalog(catalogType: CatalogType = .natural)
    case getCatalog(catalogType: CatalogType = .natural, entry: EPICDateEntry)
    case getImage(catalogType: CatalogType = .natural, entry: EPICImageEntry)
}

extension EPICEndpoint {
    enum CatalogType {
        case natural, enhanced
    }

    var catalogType: CatalogType {
        switch self {
        case let .getAvailableDates(catalogType: catalogType),
             let .getRecentCatalog(catalogType: catalogType),
             let .getCatalog(catalogType: catalogType, entry: _),
             let .getImage(catalogType: catalogType, entry: _):
            return catalogType
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
        case let .getCatalog(catalogType: _, entry: entry):
            path.append(entry.date)
        case let .getImage(catalogType: _, entry: entry):
            guard let dateParameters = entry.asDateParameters else { return nil }
            path.append(contentsOf: dateParameters)
            path.append("png")
            path.append(entry.image + ".png")
        }

        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "api.nasa.gov"
        components.path = "/" + path.joined(separator: "/")

        return components.url
    }
}

private extension EPICImageEntry {

    private var calendar: Calendar {
        Calendar(identifier: .iso8601)
    }

    var asDateParameters: [String]? {
        guard let date = Formatters.epicDateFormatter.date(from: date) else {
            return nil
        }

        let components: [Calendar.Component] = [.year, .month, .day]
        let numbers: [NSNumber] = components.map { .init(value: calendar.component($0, from: date)) }

        return numbers.compactMap(Formatters.epicParameterNumberFormatter.string(from:))
    }
}
