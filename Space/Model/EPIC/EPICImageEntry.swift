import Foundation

struct EPICImageEntry: Codable, Identifiable {
    var id: String { identifier }

    let identifier: String
    let caption: String
    let image: String
    let date: String
}
