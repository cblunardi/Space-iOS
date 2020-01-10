@testable import Space

final class DependenciesContainerMock: DependenciesContainerProtocol {
    var urlSessionServiceMock: URLSessionServiceMock = URLSessionServiceMock()
    var urlSessionService: URLSessionServiceProtocol { urlSessionServiceMock }

    var imageServiceMock: ImageServiceMock = ImageServiceMock()
    var imageService: ImageServiceProtocol { imageServiceMock }

    var spaceServiceMock: SpaceServiceMock = SpaceServiceMock()
    var spaceService: SpaceServiceProtocol { spaceServiceMock }
}
