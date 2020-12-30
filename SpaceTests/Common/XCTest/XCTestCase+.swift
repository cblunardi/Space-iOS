@testable import Space
import XCTest

extension XCTestCase {
    open override func setUp() {
        super.setUp()

        DependenciesManager.resetDependencies(DependenciesContainerMock())
    }
}
