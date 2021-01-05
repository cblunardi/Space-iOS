protocol DependenciesContainerProtocol: AnyObject {
    var urlSessionService: URLSessionServiceProtocol { get }
    var epicService: EPICServiceProtocol { get }
    var imageCacheService: ImageCacheServiceProtocol { get }
}

final class DependenciesContainer: DependenciesContainerProtocol {
    let urlSessionService: URLSessionServiceProtocol = URLSessionService.configured()
    let epicService: EPICServiceProtocol = EPICService()
    let imageCacheService: ImageCacheServiceProtocol = ImageCacheService()
}
