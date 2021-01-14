import UIKit

final class TitleHeaderView: UICollectionReusableView, ViewModelOwner {
    static let reuseIdentifier: String = "TitleHeaderView"
    static let kind: String = "Header"

    var viewModel: TitleHeaderViewModel!

    @IBOutlet private var label: UILabel!

    func bind(viewModel: TitleHeaderViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.title
    }
}
