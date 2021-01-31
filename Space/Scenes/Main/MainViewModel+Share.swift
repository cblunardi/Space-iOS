import Combine
import Foundation
import UIKit

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
                .init(message: R.string.localizable.alertGenericErrorMessage())
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
