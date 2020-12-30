@testable import Space
import Combine
import XCTest

final class HTTPServiceMock: HTTPServiceProtocol {
    var performBehaviour: (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> =
        { _ in Fail(error: URLError(.notConnectedToInternet)).eraseToAnyPublisher() }

    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        performBehaviour(request)
    }
}
