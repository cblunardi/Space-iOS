import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    private lazy var dateFormatter: DateFormatter = buildDateFormatter()
    private lazy var timeFormatter: DateFormatter = buildTimeFormatter()

    let state: CurrentValueSubject<State, Never> = .init(.initial)

    var subscriptions: Set<AnyCancellable> = .init()

    private(set) lazy var currentImage: AnyPublisher<UIImage?, Never> =
        currentEntry
            .flatMapLatestImage()
            .replaceError(with: nil)
            .share()
            .eraseToAnyPublisher()
}

extension MainViewModel {
    var currentEntry: AnyPublisher<EPICImageEntry?, Never> {
        state
            .map { $0.panningEntry ?? $0.currentEntry }
            .eraseToAnyPublisher()
    }

    var currentTitle: AnyPublisher<String?, Never> {
        currentDate
            .mapFlatMap(dateFormatter.string(from:))
            .eraseToAnyPublisher()
    }

    var currentSubtitle: AnyPublisher<String?, Never> {
        currentDate
            .mapFlatMap(timeFormatter.string(from:))
            .eraseToAnyPublisher()
    }
}

extension MainViewModel {
    func load() {
        guard
            state.value.dates.loading == false,
            state.value.dates.loaded == false
        else { return }

        state.value.dates.reload()

        dependencies
            .epicService
            .getAvailableDates()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.receive($0) })
            .store(in: &subscriptions)
    }

    private func receive(_ dates: [EPICDateEntry]) {
        state.value.receive(dates: dates)

        guard let recent = dates.first else { return }

        state.value.catalogs.reload()

        dependencies
            .epicService
            .getCatalog(from: recent)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.receive(.init(date: recent, images: $0)) })
            .store(in: &subscriptions)
    }

    private func receive(_ catalog: EPICImageCatalog) {
        state.value.receive(catalog: catalog)
    }
}

private extension MainViewModel {
    var currentDate: AnyPublisher<Date?, Never> {
        currentEntry
            .map { $0?.date }
            .mapFlatMap(Formatters.epicDateFormatter.date(from:))
            .eraseToAnyPublisher()
    }

    func buildDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    func buildTimeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter
    }
}

private extension Publisher where Output == EPICImageEntry?, Failure == Never {
    func flatMapLatestImage() -> AnyPublisher<UIImage?, Error> {
        map { entry -> AnyPublisher<UIImage?, Error> in
            guard let entry = entry else {
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            let fallbackRetrieval = dependencies
                .epicService
                .getImage(from: entry)
                .map(UIImage.init(data:))

            let retrieval = dependencies
                .imageCacheService
                .cachedImage(with: entry.image,
                             fallback: fallbackRetrieval)

            return Just(nil)
                .setFailureType(to: Error.self)
                .merge(with: retrieval)
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
