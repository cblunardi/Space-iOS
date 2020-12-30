@testable import Space
import Combine
import XCTest

final class HTTPServiceMock: HTTPServiceProtocol {
    var performBehaviour: (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> =
        { _ in Empty().eraseToAnyPublisher() }

    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        performBehaviour(request)
    }
}
