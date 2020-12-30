@testable import Space
import XCTest

final class DependenciesManagerTests: XCTestCase {
    func test_resetDependencies() {
        let mockDependencies: DependenciesContainerMock = .init()

        DependenciesManager.resetDependencies(mockDependencies)

        XCTAssert(mockDependencies === Space.dependencies)
    }
}
