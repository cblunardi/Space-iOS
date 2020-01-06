import Foundation

struct EPICImageEntry: Codable {
    let identifier: String
    let caption: String
    let image: String
    let date: String
}

extension EPICImageEntry: Identifiable {
    var id: String { identifier }
}

extension EPICImageEntry: Equatable {
    static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
