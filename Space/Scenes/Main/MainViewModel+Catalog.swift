import Combine

extension MainViewModel {
    func showCatalogPressed() {
        guard let model = state.value.entries.availableValue else { return }

        coordinator.showCatalog(model: .init(entries: model,
                                             selectedEntry: state.value.currentEntry))
            .selectedItem
            .sink { [weak self] in self?.didSelect(entry: $0) }
            .store(in: &subscriptions)
    }

    func showAboutPressed() {
        coordinator.showAbout()
    }

    private func didSelect(entry: EPICImage) {
        state.value.select(entry)
    }
}
