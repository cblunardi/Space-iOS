import Combine

extension Publisher where Failure == Never {
    func assignWeakly<Object>(to keyPath: WritableKeyPath<Object, Output>,
                              on object: Object) -> AnyCancellable where Object: AnyObject {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
