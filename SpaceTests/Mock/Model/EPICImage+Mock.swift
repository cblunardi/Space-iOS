import Foundation
@testable import Space

extension EPICImage {
    static var mock: EPICImage {
        .init(date: Date(timeIntervalSince1970: 1609202193),
              uri: "https://cblunardi-space-assets.s3.amazonaws.com/epic/epic_1b_20201229003633.png")
    }
}
