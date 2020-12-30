/// Allows enforcing weak references in protocols (directly using `weak` in protocols is not allowed as of Swift 5.3
struct WeakReference<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value? = .none) {
        self.value = value
    }
}
