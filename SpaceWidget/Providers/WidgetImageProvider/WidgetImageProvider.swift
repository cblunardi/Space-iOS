import Combine
import UIKit
import SwiftUI
import WidgetKit

struct WidgetImageProvider: TimelineProvider {
    static var subscriptions: Set<AnyCancellable> = .init()

    func placeholder(in context: Context) -> WidgetEntry {
        .placeholder(family: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        getLatest(in: context)
            .sink { completion($0) }
            .store(in: &Self.subscriptions)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> ()) {
        getLatest(in: context)
            .sink { self.receive($0, completion: completion) }
            .store(in: &Self.subscriptions)
    }
}

private extension WidgetImageProvider {
    func receive(_ entry: WidgetEntry, completion: @escaping (Timeline<Entry>) -> Void) {
        let nextUpdate: Date
        switch entry.result {
        case .failure:
            nextUpdate = .init(timeIntervalSinceNow: 60 * 5) // 5 minutes
        case .success:
            nextUpdate = .init(timeIntervalSinceNow: 60 * 60) // 1 hour
        }

        let timeline: Timeline<Entry> = .init(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

private extension WidgetImageProvider {
    func getLatest(in context: Context) -> AnyPublisher<WidgetEntry, Never> {
        dependencies.spaceService
            .retrieveLatest()
            .first()
            .compactMap { image in URL(string: image.uri).map { (image, $0) } }
            .flatMapTuple { dependencies.imageService.retrieve(from: $0.1) }
            .map { WidgetEntry(epic: $0.1.0, image: $0.0, family: context.family) }
            .catch { Just(WidgetEntry(result: .failure($0))) }
            .eraseToAnyPublisher()
    }
}
