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

    var catalogButtonVisible: AnyPublisher<Bool, Never> {
        state
            .map { $0.loading == false }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var downloadButtonVisible: AnyPublisher<Bool, Never> {
        state
            .map { $0.currentEntry != nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var isSharing: AnyPublisher<Bool, Never> {
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

    func showAboutPressed() {
        coordinator.showAbout()
    }

    private func didSelect(entry: EPICImage) {
        state.value.select(entry)
    }
}

extension MainViewModel {
    func sharePressed() {
        guard
            state.value.sharing == false,
            let entry = state.value.currentEntry,
            let url = URL(string: entry.originalImageURI)
        else { return }

        state.value.sharing = true

        dependencies.imageService
            .retrieve(from: url)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in self?.handle($0) },
                  receiveValue: { [weak self] in self?.handle($0) })
            .store(in: &subscriptions)
    }

    private func handle(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .failure:
            coordinator.showAlert(
                .init(message: R.string.localizable.mainDownloadFailure())
            )

            state.value.sharing = false

        case .finished:
            break

        }
    }

    private func handle(_ image: UIImage) {
        coordinator
            .showShare(buildShareModel(with: image),
                       completion: { self.state.value.sharing = false })
    }

    private func buildShareModel(with image: UIImage) -> ShareModel {
        let text: String? = state.value.currentEntry
            .map(\.date)
            .map(Formatters.buildLongFormatter().string(from:))
            .map { Localized.mainShareBody($0, URLConstants.appStore) }

        return .init(image: image, text: text)
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
    func flatMapLatestImage() -> AnyPublisher<UIImage?, Never> {
        map { entry -> AnyPublisher<UIImage?, Never> in
            entry
                .flatMap({ URL(string: $0.previewImageURI) })
                .map(dependencies.imageService.retrieveAndProcess(from:))
                ?? Just(nil).eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
