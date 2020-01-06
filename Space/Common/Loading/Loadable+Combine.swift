import Combine

extension Publisher {
    func mutateWeakly<T>(_ loadableKeyPath: WritableKeyPath<T, Loadable<Output, Failure>>,
                         on object: T) -> AnyCancellable
    where T: AnyObject
    {
        sink(receiveCompletion: { [weak object] completion in
            switch completion {
            case .finished:
                break
            case let .failure(error):
                object?[keyPath: loadableKeyPath].receive(error)
            }
        }, receiveValue: { [weak object] output in
            object?[keyPath: loadableKeyPath].receive(output)
        })
    }
}
