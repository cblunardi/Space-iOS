import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    private lazy var dateFormatter: DateFormatter = Formatters.buildDateFormatter()
    private lazy var timeFormatter: DateFormatter = Formatters.buildTimeFormatter()

    let coordinator: MainCoordinatorProtocol

    var subscriptions: Set<AnyCancellable> = .init()

    let state: CurrentValueSubject<State, Never> = .init(.initial)

    private(set) lazy var currentImage: AnyPublisher<UIImage?, Never> =
        currentEntry
            .flatMapLatestImage()
            .share()
            .eraseToAnyPublisher()

    init(coordinator: MainCoordinatorProtocol) {
        self.coordinator = coordinator
    }
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

    var catalogButtonVisible: AnyPublisher<Bool, Never> {
        state
            .map { $0.isLoading == false }
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
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.receiveInitial(entries: $0) })
            .store(in: &subscriptions)
    }

    private func receiveInitial(entries: [EPICImage]) {
        state.value.receive(entries: entries)

        entries
            .around(index: entries.endIndex, distance: 2)
            .compactMap { URL(string: $0.uri) }
            .forEach(dependencies.imageService.prefetch(from:))
    }
}

extension MainViewModel {
    func showCatalogPressed() {
        guard let model = state.value.entries.availableValue else { return }

        coordinator.showCatalog(model: .init(entries: model,
                                             selectedEntry: state.value.currentEntry))
            .selectedItem
            .sink { [weak self] in self?.state.value.currentEntry = $0 }
            .store(in: &subscriptions)
    }
}

private extension Publisher where Output == EPICImage?, Failure == Never {
    func flatMapLatestImage() -> AnyPublisher<UIImage?, Never> {
        map { entry -> AnyPublisher<UIImage?, Never> in
            entry
                .flatMap({ URL(string: $0.uri) })
                .map(dependencies.imageService.retrieveAndProcess(from:))
                ?? Just(nil).eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
