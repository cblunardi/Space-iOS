import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    private lazy var dateFormatter: DateFormatter = Formatters.dateFormatter
    private lazy var timeFormatter: DateFormatter = Formatters.timeFormatter

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

    var hintLabelVisible: AnyPublisher<Bool, Never> {
        let hasImage = currentImage
            .map { $0 != nil }
            .filter { $0 }
            .first()

        let enable = hasImage
            .map { _ in true }
            .delay(for: .seconds(1), scheduler: RunLoop.main)

        let disable = hasImage
            .map { _ in false }
            .delay(for: .seconds(5), scheduler: RunLoop.main)

        return Publishers.Merge3(Just(false), enable, disable)
            .eraseToAnyPublisher()
    }
}

extension MainViewModel {
    func load() {
        guard state.value.isLoading == false else { return }

        state.value.entries.reload()

        dependencies
            .spaceService
            .retrieveAll()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] in self?.receiveInitial(entries: $0) })
            .store(in: &subscriptions)
    }

    private func receiveInitial(entries: [EPICImage]) {
        state.value.receive(entries: entries)
    }
}

extension MainViewModel {
    func showCatalogPressed() {
        guard let model = state.value.entries.availableValue else { return }

        coordinator.showCatalog(model: .init(entries: model,
                                             selectedEntry: state.value.currentEntry))
            .selectedItem
            .sink { [weak self] in self?.didSelect(entry: $0) }
            .store(in: &subscriptions)
    }

    private func didSelect(entry: EPICImage) {
        state.value.select(entry)
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
