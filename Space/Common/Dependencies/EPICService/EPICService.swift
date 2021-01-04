import Combine
import Foundation

protocol EPICServiceProtocol {
    func getAvailableDates() -> AnyPublisher<[EPICDateEntry], Error>
    func getCatalog(from entry: EPICDateEntry) -> AnyPublisher<[EPICImageEntry], Error>
    func getRecentCatalog() -> AnyPublisher<[EPICImageEntry], Error>
    func getImage(from entry: EPICImageEntry) -> AnyPublisher<Data, Error>
}

final class EPICService: EPICServiceProtocol {
    private let decoder: JSONDecoder = .init()

    func getAvailableDates() -> AnyPublisher<[EPICDateEntry], Error> {
        Fail(error: CustomLocalizedError(errorDescription: "Not implemented yet"))
            .eraseToAnyPublisher()
    }

    func getCatalog(from entry: EPICDateEntry) -> AnyPublisher<[EPICImageEntry], Error> {
        Fail(error: CustomLocalizedError(errorDescription: "Not implemented yet"))
            .eraseToAnyPublisher()
    }

    func getRecentCatalog() -> AnyPublisher<[EPICImageEntry], Error> {
        Fail(error: CustomLocalizedError(errorDescription: "Not implemented yet"))
            .eraseToAnyPublisher()
    }

    func getImage(from entry: EPICImageEntry) -> AnyPublisher<Data, Error> {
        Fail(error: CustomLocalizedError(errorDescription: "Not implemented yet"))
            .eraseToAnyPublisher()
    }
}

private extension EPICService {
    func performRequest<ResponseType>(url: URL) -> AnyPublisher<ResponseType, Error> where ResponseType: Decodable {
        dependencies.urlSessionService
            .perform(request: .init(url: url))
            .validateHTTP()
            .decode(type: ResponseType.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
