protocol DependenciesContainerProtocol: AnyObject {
    var httpService: HTTPServiceProtocol { get }
}

final class DependenciesContainer: DependenciesContainerProtocol {
    var httpService: HTTPServiceProtocol = HTTPService()
}
