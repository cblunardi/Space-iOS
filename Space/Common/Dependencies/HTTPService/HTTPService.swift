import Combine
import Foundation

protocol HTTPServiceProtocol {
    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError>
}

final class HTTPService: HTTPServiceProtocol {
    typealias RequestDecorator = (URLRequest) -> URLRequest

    private let session: URLSession
    private var decorators: [RequestDecorator]

    init(decorators: [RequestDecorator] = .empty,
         session: URLSession = .default())
    {
        self.session = session
        self.decorators = decorators
    }

    func add(decorator: @escaping RequestDecorator) {
        decorators.append(decorator)
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
        return URLSession(configuration: configuration)
    }
}
