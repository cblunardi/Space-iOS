@testable import Space
import Combine
import XCTest

final class URLSessionServiceMock: URLSessionServiceProtocol {
    var performBehaviour: (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> =
        { _ in .mockFailure(with: URLError(.notConnectedToInternet)) }

    func perform(request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), URLError> {
        performBehaviour(request)
    }
}
