import Combine
import Foundation

protocol SpaceServiceProtocol {
    func retrieveEPIC() -> AnyPublisher<[EPICImage], Error>
    func retrieveEPICLatest() -> AnyPublisher<EPICImage, Error>
}

final class SpaceService: SpaceServiceProtocol {
    private let components: URLComponents
    private let decoder: JSONDecoder = .configured

    init(scheme: String = "https",
         host: String = "d2quyyen2nzp5v.cloudfront.net",
         port: Int? = nil)
    {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port

        self.components = components
    }

    func retrieveEPIC() -> AnyPublisher<[EPICImage], Swift.Error> {
        let components = self.components.setting(\.path, to: "/epic")
        guard let url = components.url else {
            return Fail(error: Error.urlConstruction)
                .eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
            .setting(\.httpMethod, to: "GET")

        return dependencies.urlSessionService
            .perform(request: request)
            .map(\.data)
            .decode(type: [EPICImage].self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    func retrieveEPICLatest() -> AnyPublisher<EPICImage, Swift.Error> {
        let components = self.components.setting(\.path, to: "/epic/latest")
        guard let url = components.url else {
            return Fail(error: Error.urlConstruction)
                .eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
            .setting(\.httpMethod, to: "GET")

        return dependencies.urlSessionService
            .perform(request: request)
            .map(\.data)
            .decode(type: EPICImage.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension SpaceService {
    enum Error: Swift.Error {
        case urlConstruction
    }
}

private extension JSONDecoder {
    static var configured: JSONDecoder {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
