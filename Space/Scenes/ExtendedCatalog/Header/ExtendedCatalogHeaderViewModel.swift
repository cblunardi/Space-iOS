struct ExtendedCatalogHeaderViewModel: ViewModel, Hashable, Identifiable {
    let model: Model
}

extension ExtendedCatalogHeaderViewModel {
    typealias Model = ExtendedCatalogViewModel.Section

    var id: Int {
        model.hashValue
    }

    var title: String {
        model.date
    }
}
