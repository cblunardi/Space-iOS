@testable import Space

final class DependenciesContainerMock: DependenciesContainerProtocol {
    var urlSessionService: URLSessionServiceProtocol = URLSessionServiceMock()
}
