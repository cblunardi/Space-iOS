import UIKit

protocol StoryboardLoadable: UIViewController {
    static var storyboardName: String { get }
    static var storyboardIdentifier: String { get }

    static func instantiate(from storyboard: UIStoryboard?) -> Self
}

extension StoryboardLoadable {
    static func instantiate() -> Self {
        instantiate(from: .none)
    }
}

extension StoryboardLoadable {
    static var storyboardName: String {
        String(describing: Self.self)
            .replacingOccurrences(of: "ViewController", with: String.empty)
    }

    static var storyboardIdentifier: String {
        String(describing: Self.self)
    }

    private static var bundle: Bundle {
        .init(for: Self.self)
    }

    static func instantiate(from storyboard: UIStoryboard?) -> Self {
        (storyboard ?? UIStoryboard(name: storyboardName, bundle: bundle))
            .instantiateViewController(identifier: storyboardIdentifier)
    }
}
