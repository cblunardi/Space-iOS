import Combine
@testable import Space

final class SpaceServiceMock: SpaceServiceProtocol {
    var retrieveEPICBehaviour: () -> AnyPublisher<[EPICImage], Error> = { .mockFailure }
    func retrieveEPIC() -> AnyPublisher<[EPICImage], Error> {
        retrieveEPICBehaviour()
    }
}
