import Combine
import Lottie
import UIKit

final class AboutHeaderCell: UICollectionViewCell, ViewModelOwner, LoadableView {
    static let reuseIdentifier: String = "AboutHeaderCell"

    var viewModel: AboutHeaderViewModel!

    @IBOutlet private var animationContainerView: UIView!
    @IBOutlet private var textView: UITextView!

    lazy var loadingView: AnimationView = makeLoadingView(in: animationContainerView)

    func bind(viewModel: AboutHeaderViewModel) {
        self.viewModel = viewModel

        textView.text = viewModel.text
        set(loading: true)
    }
}
