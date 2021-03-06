import Combine
import Foundation

protocol URLSessionServiceProtocol {
    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

final class URLSessionService: URLSessionServiceProtocol {
    typealias RequestDecorator = (URLRequest) -> URLRequest

    private let session: URLSession
    private var decorators: [RequestDecorator]

    init(decorators: [RequestDecorator] = .empty,
         session: URLSession = .default())
    {
        self.session = session
        self.decorators = decorators
    }

    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        let decoratedRequest: URLRequest = decorators.reduce(request, { $1($0) })

        return session
            .dataTaskPublisher(for: decoratedRequest)
            .retry(3)
            .eraseToAnyPublisher()
    }
}

private extension URLSession {
    static func `default`(setting delegate: URLSessionDelegate? = nil) -> URLSession {
        let configuration: URLSessionConfiguration = .default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.waitsForConnectivity = true
        configuration.httpShouldUsePipelining = true
        configuration.networkServiceType = .responsiveData
        configuration.timeoutIntervalForResource = 30.0
        configuration.urlCache = .init(memoryCapacity: 32 * .mega,
                                       diskCapacity: 8 * .giga)
        return URLSession(configuration: configuration)
    }
}

extension URLSessionService {
    static func configured() -> URLSessionService {
        .init(decorators: [])
    }
}
