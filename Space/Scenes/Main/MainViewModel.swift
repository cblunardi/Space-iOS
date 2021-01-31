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
            .retrieveImage()
            .multicast { CurrentValueSubject(nil) }
            .autoconnect()
            .eraseToAnyPublisher()

    init(coordinator: MainCoordinatorProtocol) {
        self.coordinator = coordinator

        configure()
    }
}

extension MainViewModel {
    var currentEntry: AnyPublisher<EPICImage?, Never> {
        state
            .map { $0.panningEntry ?? $0.currentEntry }
            .removeDuplicates()
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

    var imageLoading: AnyPublisher<Bool, Never> {
        currentImage
            .map { $0 == nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var catalogButtonVisible: AnyPublisher<Bool, Never> {
        state
            .map(\.entries.loaded)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var shareButtonVisible: AnyPublisher<Bool, Never> {
        state
            .map { $0.sharing  == false && $0.currentEntry != nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var shareActivityIndicatorVisible: AnyPublisher<Bool, Never> {
        state
            .map(\.sharing)
            .removeDuplicates()
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
            .delay(for: .seconds(7), scheduler: RunLoop.main)

        return Publishers.Merge3(Just(false), enable, disable)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var hintLabelTitle: String {
        Localized.mainHintText()
    }
}

extension MainViewModel {
    func load() {
        guard state.value.entries.loading == false else { return }

        state.value.entries.reload()

        dependencies.spaceService
            .retrieveAll()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in self?.handle($0) },
                  receiveValue: { [weak self] in self?.receive($0) })
            .store(in: &subscriptions)
    }

    private func receive(_ entries: [EPICImage]) {
        state.value.receive(entries: entries)
    }

    private func handle(_ completion: Subscribers.Completion<Error>) {
        guard case .failure = completion else { return }

        state.value.entries = .reset

        let action: UIAlertAction = .init(title: Localized.mainFailureRetryAction(),
                                          style: .default,
                                          handler: { _ in self.load() })

        coordinator.showAlert(.init(message: Localized.mainFailureMessage(),
                                    actions: [action]))
    }
}

private extension MainViewModel {
    func configure() {
        Timer.publish(every: 30 * .secondsInMinute, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in self?.load() }
            .store(in: &subscriptions)
    }
}

private extension Publisher where Output == EPICImage?, Failure == Never {
    func retrieveImage() -> AnyPublisher<UIImage?, Never> {
        map { entry -> AnyPublisher<UIImage?, Never> in
            entry
                .flatMap { URL(string: $0.previewImageURI) }
                .map(dependencies.imageService.retrieveAndProcess(from:))
                ?? Just(nil).eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
