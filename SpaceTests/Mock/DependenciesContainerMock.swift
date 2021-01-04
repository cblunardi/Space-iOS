@testable import Space

final class DependenciesContainerMock: DependenciesContainerProtocol {
    var urlSessionServiceMock: URLSessionServiceMock = URLSessionServiceMock()
    var urlSessionService: URLSessionServiceProtocol { urlSessionServiceMock }

    var epicServiceMock: EPICServiceMock = EPICServiceMock()
    var epicService: EPICServiceProtocol { epicServiceMock }
}
