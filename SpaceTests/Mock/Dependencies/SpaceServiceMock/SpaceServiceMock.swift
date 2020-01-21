import Combine
@testable import Space

final class SpaceServiceMock: SpaceServiceProtocol {
    var retrieveAllBehaviour: () -> AnyPublisher<[EPICImage], Error> = { .mockFailure }
    func retrieveAll() -> AnyPublisher<[EPICImage], Error> {
        retrieveAllBehaviour()
    }

    var retrieveLatestBehaviour: () -> AnyPublisher<EPICImage, Error> = { .mockFailure }
    func retrieveLatest() -> AnyPublisher<EPICImage, Error> {
        retrieveLatestBehaviour()
    }

    var retrievePageBehaviour: (PageRequest) -> AnyPublisher<PageResponse<EPICImage>, Error> = { _ in .mockFailure }
    func retrievePage(_ request: PageRequest) -> AnyPublisher<PageResponse<EPICImage>, Error> {
        retrievePageBehaviour(request)
    }
}
