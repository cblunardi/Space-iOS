import Foundation

final class AppService: AppServiceProtocol {
    func open(url: URL, completion: @escaping (Bool) -> Void) {
        assertionFailure("Not available in Widget")
    }
}
