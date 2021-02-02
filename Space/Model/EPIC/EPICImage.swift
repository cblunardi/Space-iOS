import Foundation

struct EPICImage: Codable {
    let date: Date
    let name: String
}

extension EPICImage: Equatable, Hashable {}

extension EPICImage: Comparable {
    static func < (lhs: EPICImage, rhs: EPICImage) -> Bool {
        lhs.date < rhs.date
    }
}

extension EPICImage {
    var previewImageURI: String {
        dependencies.spaceService.previewImageURL(for: name)?.absoluteString ?? ""
    }

    var originalImageURI: String {
        dependencies.spaceService.originalImageURL(for: name)?.absoluteString ?? ""
    }
}
