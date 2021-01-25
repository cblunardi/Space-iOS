@testable import Space
import XCTest

final class StoryboardLoadableTests: XCTestCase {
    func test_initialize_defaultStoryboard() {
        let viewController = MockSceneViewController.instantiate()

        viewController.loadViewIfNeeded()

        XCTAssertEqual(viewController.mockLabel?.text, "Mock Label")
    }
}
