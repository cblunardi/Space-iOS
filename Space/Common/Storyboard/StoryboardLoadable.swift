import UIKit

protocol StoryboardLoadable: UIViewController {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }

    static func initialize(from storyboard: UIStoryboard?) -> Self
}

extension StoryboardLoadable {
    static func initialize() -> Self {
        initialize(from: .none)
    }
}

extension StoryboardLoadable {
    static var storyboardName: String {
        String(describing: Self.self)
    }

    static var storyboardIdentifier: String {
        storyboardName
    }

    private static var bundle: Bundle {
        .init(for: Self.self)
    }

    static func initialize(from storyboard: UIStoryboard?) -> Self {
        (storyboard ?? UIStoryboard(name: storyboardName, bundle: bundle))
            .instantiateViewController(identifier: storyboardIdentifier)
    }
}
