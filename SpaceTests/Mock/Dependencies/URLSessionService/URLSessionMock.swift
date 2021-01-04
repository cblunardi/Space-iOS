@testable import Space
import Foundation

final class URLSessionDataTaskMock: URLSessionDataTask {
    override init() {}
}

final class URLSessionMock: URLSession {
    typealias DataTaskCompletionHandler = (Data?, URLResponse?, Error?) -> Void

    var dataTaskBehaviour: (URLRequest, DataTaskCompletionHandler) -> URLSessionDataTask = { _, completion in
        completion(nil, nil, CustomLocalizedError(errorDescription: nil))
        return URLSessionDataTaskMock()
    }

    override func dataTask(with request: URLRequest,
                           completionHandler: @escaping DataTaskCompletionHandler) -> URLSessionDataTask
    {
        dataTaskBehaviour(request, completionHandler)
    }
}
