import Foundation

struct EPICImage: Codable {
    let date: Date
    let uri: String
}

extension EPICImage: Equatable {}

extension EPICImage: Comparable {
    static func < (lhs: EPICImage, rhs: EPICImage) -> Bool {
        lhs.date < rhs.date
    }
}