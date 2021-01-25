import UIKit

protocol AppServiceProtocol {
    func open(url: URL, completion: @escaping (Bool) -> Void)

    func open(url: URL)
}

extension AppServiceProtocol {
    func open(url: URL) {
        open(url: url, completion: { _ in })
    }
}
