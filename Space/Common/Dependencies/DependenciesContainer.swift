protocol DependenciesContainerProtocol: AnyObject {
    var urlSessionService: URLSessionServiceProtocol { get }
}

final class DependenciesContainer: DependenciesContainerProtocol {
    var urlSessionService: URLSessionServiceProtocol = URLSessionService.configured()
}
