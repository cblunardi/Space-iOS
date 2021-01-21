import SwiftUI
import WidgetKit

struct WidgetEntry: TimelineEntry {
    let date: Date = .init()
    let result: Result<Content, Error>
}

extension WidgetEntry {
    struct Content {
        let title: String
        let image: UIImage
    }

    static func placeholder(family: WidgetFamily) -> WidgetEntry {
        .init(result: .success(.placeholder(family: family)))
    }

    init(epic: EPICImage, image: UIImage, family: WidgetFamily) {
        self.init(result: .success(.init(epic: epic, image: image, family: family)))
    }
}

extension WidgetEntry.Content {
    static func placeholder(family: WidgetFamily) -> Self {
        .init(title: .titlePlaceholder(family: family),
              image: UIImage(named: "PlaceholderImage")!)
    }

    init(epic: EPICImage, image: UIImage, family: WidgetFamily) {
        self.init(title: .title(date: epic.date, family: family), image: image)
    }
}

private extension String {
    static func titlePlaceholder(family: WidgetFamily) -> String {
        title(date: .placeholder, family: family)
    }

    static func title(date: Date, family: WidgetFamily) -> String {
        let formatter: DateFormatter
        switch family {
        case .systemSmall: formatter = Formatters.shortFormatter
        case .systemMedium: formatter = Formatters.mediumFormatter
        case .systemLarge: formatter = Formatters.longFormatter
        @unknown default: formatter = Formatters.mediumFormatter
        }

        return formatter.string(from: date)
    }
}

private extension Date {
    static var placeholder: Date { .init(timeIntervalSinceReferenceDate: 632675977) }
}
