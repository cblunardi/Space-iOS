import Combine
import Foundation

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func validateHTTP(acceptCodes: Set<Int> = .init(ranges: [200..<300])) -> AnyPublisher<Data, URLError> {
        flatMap { (data, response) -> AnyPublisher<Data, URLError> in
            guard let httpResponse = response as? HTTPURLResponse else {
                return Fail(error: URLError(.unknown))
                    .eraseToAnyPublisher()
            }

            guard acceptCodes.contains(httpResponse.statusCode) else {
                return Fail(error: URLError(.unknown))
                    .eraseToAnyPublisher()
            }

            return Just(data)
                .setFailureType(to: URLError.self)
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
