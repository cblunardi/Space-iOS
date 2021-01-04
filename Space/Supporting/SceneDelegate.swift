import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let appCoordinator: AppCoordinator = .init()
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let window = self.window else {
            fatalError()
        }

        appCoordinator.start(in: window)
    }
}

