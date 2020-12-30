extension Coordinator {
    init(viewController: ViewControllerType) {
        self.init(viewController: WeakReference(viewController))
    }
}
