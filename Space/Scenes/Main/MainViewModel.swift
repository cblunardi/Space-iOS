import Combine
import Foundation
import UIKit

final class MainViewModel: ViewModel {
    private lazy var dateFormatter: DateFormatter = buildDateFormatter()
    private lazy var timeFormatter: DateFormatter = buildTimeFormatter()

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
}

extension MainViewModel {
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

private extension MainViewModel {
    var currentDate: AnyPublisher<Date?, Never> {
        latestEntry
            .map { $0?.date }
            .mapFlatMap(DateFormatters.epicDateFormatter.date(from:))
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

            return dependencies.epicService.getImage(from: entry)
                .map(UIImage.init(data:))
                .eraseToAnyPublisher()
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}
