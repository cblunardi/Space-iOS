protocol DependenciesContainerProtocol: AnyObject {
    var urlSessionService: URLSessionServiceProtocol { get }
    var spaceService: SpaceServiceProtocol { get }
    var imageService: ImageServiceProtocol { get }
    var appService: AppServiceProtocol { get }
}

final class DependenciesContainer: DependenciesContainerProtocol {
    let urlSessionService: URLSessionServiceProtocol = URLSessionService.configured()
    let spaceService: SpaceServiceProtocol = SpaceService()
    let imageService: ImageServiceProtocol = ImageService()
    let appService: AppServiceProtocol = AppService()
}
