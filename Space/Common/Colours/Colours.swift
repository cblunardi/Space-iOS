import UIKit

struct Colors {
    private init() {}

    static let accent: UIColor = UIColor(named: "AccentColor")!

    struct Catalog {
        private init() {}

        static let day: UIColor = UIColor(named: "CatalogDay")!
        static let daySelected: UIColor = UIColor(named: "CatalogDaySelected")!
        static let dayUnavailable: UIColor = UIColor(named: "CatalogDayUnavailable")!
    }
}
