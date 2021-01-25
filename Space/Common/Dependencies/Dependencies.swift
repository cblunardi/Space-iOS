private(set) var dependencies: DependenciesContainerProtocol = DependenciesManager.buildDependencies()

struct DependenciesManager {
    fileprivate static func buildDependencies() -> DependenciesContainerProtocol {
        DependenciesContainer()
    }

    #if DEBUG
    static func resetDependencies(_ newDependencies: DependenciesContainerProtocol) {
        dependencies = newDependencies
    }
    #endif

    private init() {}
}
