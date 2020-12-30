@testable import Space

final class DependenciesContainerMock: DependenciesContainerProtocol {
    var httpService: HTTPServiceProtocol = HTTPServiceMock()
}
