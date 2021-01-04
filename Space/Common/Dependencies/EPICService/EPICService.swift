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

    func getAvailableDates() -> AnyPublisher<[EPICDateEntry], Swift.Error> {
        performRequest(endpoint: .getAvailableDates())
    }

    func getCatalog(from entry: EPICDateEntry) -> AnyPublisher<[EPICImageEntry], Swift.Error> {
        performRequest(endpoint: .getCatalog(entry: entry))
    }

    func getRecentCatalog() -> AnyPublisher<[EPICImageEntry], Swift.Error> {
        performRequest(endpoint: .getRecentCatalog())
    }

    func getImage(from entry: EPICImageEntry) -> AnyPublisher<Data, Swift.Error> {
        performRequest(endpoint: .getImage(entry: entry))
    }
}

// MARK: - Errors
extension EPICService {
    enum Error: Swift.Error {
        case urlConstruction
    }
}

private extension EPICService {
    func makeFailure<ResultType>(_ error: Error) -> AnyPublisher<ResultType, Swift.Error> {
        Fail(error: error).eraseToAnyPublisher()
    }
}

// MARK: - Requests
private extension EPICService {
    func performRequest<ResponseType>(endpoint: EPICEndpoint) -> AnyPublisher<ResponseType, Swift.Error> where ResponseType: Decodable {
        endpoint.url.map(performRequest(url:))
            ?? makeFailure(.urlConstruction)
    }

    private func performRequest<ResponseType>(url: URL) -> AnyPublisher<ResponseType, Swift.Error> where ResponseType: Decodable {
        dependencies.urlSessionService
            .perform(request: .init(url: url))
            .validateHTTP()
            .decode(type: ResponseType.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
