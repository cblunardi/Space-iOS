import UIKit

final class AppService: AppServiceProtocol {
    func open(url: URL, completion: @escaping (Bool) -> Void) {
        guard UIApplication.shared.canOpenURL(url) else {
            completion(false)
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
