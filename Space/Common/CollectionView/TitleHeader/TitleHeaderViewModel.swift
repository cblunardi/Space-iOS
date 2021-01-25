struct TitleHeaderViewModel: ViewModel, Hashable, Identifiable {
    var id: String { title }

    let title: String
}
