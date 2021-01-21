import Foundation

extension DispatchQueue {
    static var diffing: DispatchQueue = .global(qos: .userInteractive)
}
