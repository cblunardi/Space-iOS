import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    let latestEntry: AnyPublisher<EPICImageEntry?, Never> =
        dependencies.epicService
            .getRecentCatalog()
            .map(\.last)
            .replaceError(with: .none)
            .share()
            .eraseToAnyPublisher()

    private(set) lazy var currentImage: AnyPublisher<UIImage?, Never> =
        latestEntry
            .flatMapLatestImage()
            .replaceError(with: nil)
            .share()
            .eraseToAnyPublisher()

    private(set) lazy var currentTitle: AnyPublisher<String?, Never> =
        latestEntry
            .map { $0?.date }
            .eraseToAnyPublisher()
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
