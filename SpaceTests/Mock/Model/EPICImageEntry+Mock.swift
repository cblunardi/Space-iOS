@testable import Space

extension EPICImageEntry {
    static var mock: EPICImageEntry {
        .init(identifier: "20201229003633",
              caption: "This image was taken by NASA's EPIC camera onboard the NOAA DSCOVR spacecraft",
              image: "epic_1b_20201229003633",
              date: "2020-12-29 00:31:45")
    }
}
