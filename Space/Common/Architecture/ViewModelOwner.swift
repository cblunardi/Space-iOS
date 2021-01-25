protocol ViewModelOwner {
    associatedtype ViewModelType: ViewModel

    var viewModel: ViewModelType! { get }

    func bind(viewModel: ViewModelType)
}
