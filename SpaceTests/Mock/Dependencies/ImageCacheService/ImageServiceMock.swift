@testable import Space
import Combine
import Foundation
import UIKit

final class ImageServiceMock: ImageServiceProtocol {
    var retrieveBehaviour: (URL) -> AnyPublisher<UIImage, Error> = { _ in .mockFailure }
    func retrieve(from url: URL) -> AnyPublisher<UIImage, Error> {
        retrieveBehaviour(url)
    }
}
