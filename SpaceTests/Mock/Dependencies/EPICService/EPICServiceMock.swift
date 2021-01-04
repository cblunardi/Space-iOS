@testable import Space
import Combine
import Foundation

final class EPICServiceMock: EPICServiceProtocol {

    var getAvailableDatesBehaviour: () -> AnyPublisher<[EPICDateEntry], Error> = { .mockFailure }
    func getAvailableDates() -> AnyPublisher<[EPICDateEntry], Error> {
        getAvailableDatesBehaviour()
    }

    var getCatalogBehaviour: (EPICDateEntry) -> AnyPublisher<[EPICImageEntry], Error> = { _ in  .mockFailure }
    func getCatalog(from entry: EPICDateEntry) -> AnyPublisher<[EPICImageEntry], Error> {
        getCatalogBehaviour(entry)
    }

    var getRecentCatalogBehaviour: () -> AnyPublisher<[EPICImageEntry], Error> = { .mockFailure }
    func getRecentCatalog() -> AnyPublisher<[EPICImageEntry], Error> {
        getRecentCatalogBehaviour()
    }

    var getImageBehaviour: (EPICImageEntry) -> AnyPublisher<Data, Error> = { _ in  .mockFailure }
    func getImage(from entry: EPICImageEntry) -> AnyPublisher<Data, Error> {
        getImageBehaviour(entry)
    }
}
