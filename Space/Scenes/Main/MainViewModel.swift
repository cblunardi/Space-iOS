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
    var currentEntry: AnyPublisher<EPICImage?, Never> {
        state
            .map { $0.panningEntry ?? $0.currentEntry }
            .eraseToAnyPublisher()
    }

    var currentTitle: AnyPublisher<String?, Never> {
        currentEntry
            .mapFlatMap { [weak dateFormatter] in dateFormatter?.string(from: $0.date) }
            .eraseToAnyPublisher()
    }

    var currentSubtitle: AnyPublisher<String?, Never> {
        currentEntry
            .mapFlatMap { [weak timeFormatter] in timeFormatter?.string(from: $0.date) }
            .eraseToAnyPublisher()
    }
}

extension MainViewModel {
    func load() {
        guard state.value.isLoading == false else { return }

        state.value.entries.reload()

        dependencies
            .spaceService
            .retrieveEPIC()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.receiveInitial(entries: $0) })
            .store(in: &subscriptions)
    }

    private func receiveInitial(entries: [EPICImage]) {
        state.value.receive(entries: entries)

        entries
            .suffix(5)
            .compactMap { URL(string: $0.uri) }
            .forEach(dependencies.imageService.prefetch(from:))
    }
}

private extension MainViewModel {
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

private extension Publisher where Output == EPICImage?, Failure == Never {
    func flatMapLatestImage() -> AnyPublisher<UIImage?, Error> {
        map { entry -> AnyPublisher<UIImage?, Error> in
            guard let url = entry.flatMap({ URL(string: $0.uri) }) else {
                return Just(nil)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            let noImage: AnyPublisher<UIImage?, Error> = Just(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()

            let imageRetrieval = dependencies
                .imageService
                .retrieve(from: url)
                .map { Optional($0) }
                .eraseToAnyPublisher()

            return Publishers.Merge(noImage, imageRetrieval)
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
