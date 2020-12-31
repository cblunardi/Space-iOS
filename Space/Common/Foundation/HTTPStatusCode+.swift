extension Range where Bound == HTTPStatusCode {
    /// - informational: This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and is terminated by an empty line.
    static var informational: Self { .continue ..< .ok }

    /// - success: This class of status codes indicates the action requested by the client was received, understood, accepted, and processed successfully.
    static var success: Self { .ok ..< .multipleChoices }

    /// - redirection: This class of status code indicates the client must take additional action to complete the request.
    static var redirection: Self { .multipleChoices ..< .badRequest }

    /// - clientError: This class of status code is intended for situations in which the client seems to have erred.
    static var clientError: Self { .badRequest ..< .internalServerError }

    /// - serverError: This class of status code indicates the server failed to fulfill an apparently valid request.
    static var serverError: Self { .internalServerError ..< .networkAuthenticationRequired }
}

extension HTTPStatusCode: Comparable {
    static func < (lhs: HTTPStatusCode, rhs: HTTPStatusCode) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension HTTPStatusCode: Strideable {
    func distance(to other: HTTPStatusCode) -> Int {
        rawValue.distance(to: other.rawValue)
    }

    func advanced(by n: Int) -> HTTPStatusCode {
        HTTPStatusCode(rawValue: rawValue.advanced(by: n)) ?? .unknown
    }
}
