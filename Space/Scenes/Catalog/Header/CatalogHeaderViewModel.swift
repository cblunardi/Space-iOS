struct CatalogHeaderViewModel: ViewModel, Hashable, Identifiable {
    let model: Model
}

extension CatalogHeaderViewModel {
    typealias Model = CatalogViewModel.Section

    var id: Int {
        model.hashValue
    }

    var title: String {
        model.date
    }
}
