protocol DependenciesContainerProtocol: AnyObject {
    var urlSessionService: URLSessionServiceProtocol { get }
    var spaceService: SpaceServiceProtocol { get }
    var imageService: ImageServiceProtocol { get }
}

final class DependenciesContainer: DependenciesContainerProtocol {
    let urlSessionService: URLSessionServiceProtocol = URLSessionService.configured()
    let spaceService: SpaceServiceProtocol = SpaceService()
    let imageService: ImageServiceProtocol = ImageService()
}
