import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    private lazy var dateFormatter: DateFormatter = buildDateFormatter()
    private lazy var timeFormatter: DateFormatter = buildTimeFormatter()

    private let state: CurrentValueSubject<State, Never> = .init(.initial)

    private var subscriptions: Set<AnyCancellable> = .init()

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
            .map(\.currentEntry)
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
            currentState.dates.loading == false,
            currentState.dates.loaded == false
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
        state.value.dates.receive(dates)

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
        let previousCatalogs = state.value.catalogs.availableValue ?? []

        state.value.catalogs.receive(previousCatalogs + [catalog])

        state.value.currentEntry = state.value.currentEntry ?? catalog.images.first
    }
}

extension MainViewModel {
    func didRecognize(panning: CGFloat) {}
}

private extension MainViewModel {
    var currentDate: AnyPublisher<Date?, Never> {
        currentEntry
            .map { $0?.date }
            .mapFlatMap(Formatters.epicDateFormatter.date(from:))
            .eraseToAnyPublisher()
    }

    var currentState: State { state.value }

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

            return dependencies.epicService.getImage(from: entry)
                .map(UIImage.init(data:))
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
