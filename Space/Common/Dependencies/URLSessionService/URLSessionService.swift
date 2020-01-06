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
            .eraseToAnyPublisher()
    }
}

private extension URLSession {
    static func `default`(setting delegate: URLSessionDelegate? = nil) -> URLSession {
        let configuration: URLSessionConfiguration = .default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = .init(memoryCapacity: 512 * .megabyte,
                                       diskCapacity: 1024 * .megabyte)
        return URLSession(configuration: configuration)
    }
}

extension URLSessionService {
    static func configured() -> URLSessionService {
        .init(decorators: [publicNASAAPIDecorator])
    }
}

private extension URLSessionService {
    private static var publicNASAAPIDecorator: RequestDecorator {
        let decorator: RequestDecorator = { request in
            guard
                let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else {
                return request
            }

            components.queryItems = components.queryItems ?? []
                + [URLQueryItem(name: "api_key", value: Secrets.publicNASAAPIKey)]

            guard let decoratedURL = components.url else {
                return request
            }

            return request.setting(\.url, to: decoratedURL)
        }

        return decorator
    }
}

extension URLRequest: Mutable {}
