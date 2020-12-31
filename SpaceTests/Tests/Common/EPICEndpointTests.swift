@testable import Space
import XCTest

final class EPICEndpointTests: XCTestCase {
    func test_getAvailableDates_url() {
        let uut: EPICEndpoint = .getAvailableDates(catalogType: .natural)

        XCTAssertEqual(uut.url?.absoluteString, "https://api.nasa.gov/EPIC/api/natural/all")
    }

    func test_getRecentCatalog_url() {
        let uut: EPICEndpoint = .getRecentCatalog(catalogType: .natural)

        XCTAssertEqual(uut.url?.absoluteString, "https://api.nasa.gov/EPIC/api/natural/images")
    }

    func test_getCatalog_url() {
        let uut: EPICEndpoint = .getCatalog(catalogType: .natural, entry: .mock)

        XCTAssertEqual(uut.url?.absoluteString, "https://api.nasa.gov/EPIC/api/natural/2020-12-29")
    }

    func test_getImage_url() {
        let uut: EPICEndpoint = .getImage(catalogType: .natural, entry: .mock)

        XCTAssertEqual(uut.url?.absoluteString, "https://api.nasa.gov/EPIC/archive/natural/2020/12/29/png/epic_1b_20201229003633.png")
    }
}
