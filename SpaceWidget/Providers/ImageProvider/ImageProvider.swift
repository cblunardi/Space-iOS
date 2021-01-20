import Combine
import UIKit
import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    static var subscriptions: Set<AnyCancellable> = .init()

    func placeholder(in context: Context) -> ImageEntry {
        .init(content: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (ImageEntry) -> ()) {
        getLatest()
            .sink { completion($0) }
            .store(in: &Self.subscriptions)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ImageEntry>) -> ()) {
        getLatest()
            .sink { self.receive($0, completion: completion) }
            .store(in: &Self.subscriptions)
    }
}

private extension Provider {
    func receive(_ entry: ImageEntry, completion: @escaping (Timeline<Entry>) -> Void) {
        let nextUpdate: Date
        switch entry.content {
        case .failure, .placeholder:
            nextUpdate = .init(timeIntervalSinceNow: 60 * 5) // 5 minutes
        case .image:
            nextUpdate = .init(timeIntervalSinceNow: 60 * 60) // 1 hour
        }

        let timeline: Timeline<Entry> = .init(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

private extension Provider {
    func getLatest() -> AnyPublisher<ImageEntry, Never> {
        dependencies.spaceService
            .retrieveEPICLatest()
            .first()
            .compactMap { image in URL(string: image.uri).map { (image, $0) } }
            .flatMapTuple { dependencies.imageService.retrieve(from: $0.1) }
            .map { ImageEntry(entry: $0.1.0, image: $0.0) }
            .catch { Just(ImageEntry(content: .failure($0))) }
            .eraseToAnyPublisher()
    }
}

struct ImageEntry: TimelineEntry {
    let date: Date = .init()
    let content: Content
}

extension ImageEntry {
    enum Content {
        case placeholder
        case failure(Error)
        case image(Title, UIImage)

        init(entry: EPICImage, image: UIImage) {
            self = .image(.init(date: entry.date), image)
        }
    }

    init(entry: EPICImage, image: UIImage) {
        self.init(content: .init(entry: entry, image: image))
    }
}

extension ImageEntry.Content {
    struct Title {
        let small: String
        let medium: String
        let large: String
    }
}

extension ImageEntry.Content.Title {
    static var placeholder: Self {
        self.init(date: Date(timeIntervalSinceReferenceDate: 632675977))
    }

    init(date: Date) {
        self.init(small: Formatters.shortFormatter.string(from: date),
                  medium: Formatters.mediumFormatter.string(from: date),
                  large: Formatters.longFormatter.string(from: date))
    }
}
