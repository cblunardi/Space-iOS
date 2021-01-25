@testable import Space
import Combine
import XCTest

final class URLSessionServiceMock: URLSessionServiceProtocol {
    typealias PerformOutput = AnyPublisher<(data: Data, response: URLResponse), URLError>
    var performBehaviour: (URLRequest) -> PerformOutput = { _ in
        .mockFailure(with: URLError(.notConnectedToInternet))
    }

    func perform(request: URLRequest) -> PerformOutput {
        performBehaviour(request)
    }
}
