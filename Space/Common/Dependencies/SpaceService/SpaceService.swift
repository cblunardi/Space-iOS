import Combine
import Foundation

protocol SpaceServiceProtocol {
    func retrieveAll() -> AnyPublisher<[EPICImage], Error>
    func retrieveLatest() -> AnyPublisher<EPICImage, Error>
    func retrievePage(_ request: PageRequest) -> AnyPublisher<PageResponse<EPICImage>, Error>

    func previewImageURL(for name: String) -> URL?
    func originalImageURL(for name: String) -> URL?
}

final class SpaceService: SpaceServiceProtocol {
    private let components: URLComponents
    private let decoder: JSONDecoder = .configured

    init(scheme: String = "https",
         host: String = URLConstants.backendHost,
         port: Int? = nil)
    {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port

        self.components = components
    }

    func retrieveAll() -> AnyPublisher<[EPICImage], Swift.Error> {
        retrieve(path: "/epic/all")
    }

    func retrieveLatest() -> AnyPublisher<EPICImage, Swift.Error> {
        retrieve(path: "/epic/latest")
    }

    func retrievePage(_ request: PageRequest) -> AnyPublisher<PageResponse<EPICImage>, Swift.Error> {
        retrieve(query: request.asQueryItems,
                 path: "/epic")
    }

    func previewImageURL(for name: String) -> URL? {
        components
            .setting(\.path, to: "/epic/preview/" + name + ".jpg")
            .url
    }

    func originalImageURL(for name: String) -> URL? {
        components
            .setting(\.path, to: "/epic/" + name + ".png")
            .url
    }
}

private extension SpaceService {
    func retrieve<T>(query: [URLQueryItem]? = .none, path: String)
        -> AnyPublisher<T, Swift.Error>
        where T: Decodable
    {
        let requestComponents: URLComponents = components
            .setting(\.path, to: path)
            .setting(\.queryItems, to: query)

        guard let url = requestComponents.url else {
            return Fail(error: Error.urlConstruction)
                .eraseToAnyPublisher()
        }

        let request = URLRequest(url: url)
            .setting(\.httpMethod, to: "GET")

        return dependencies.urlSessionService
            .perform(request: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

extension SpaceService {
    enum Error: Swift.Error {
        case urlConstruction
    }
}

private extension PageRequest {
    var asQueryItems: [URLQueryItem] {
        [
            .init(name: "page", value: page.description),
            .init(name: "per", value: per.description)
        ]
    }
}

private extension JSONDecoder {
    static var configured: JSONDecoder {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
