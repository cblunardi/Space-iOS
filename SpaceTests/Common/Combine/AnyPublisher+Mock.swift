import Combine

extension Publisher {
    static var mockFailure: AnyPublisher<Output, Error> {
        mockFailure(with: MockError())
    }

    static func mockFailure<ErrorType>(with error: ErrorType) -> AnyPublisher<Output, ErrorType> {
        Fail(error: error)
            .eraseToAnyPublisher()
    }
}
