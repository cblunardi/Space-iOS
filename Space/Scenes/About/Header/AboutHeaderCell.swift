import Combine
import Lottie
import UIKit

final class AboutHeaderCell: UICollectionViewCell, LoadableView {
    @IBOutlet private var animationContainerView: UIView!

    lazy var loadingView: AnimationView = makeLoadingView(in: animationContainerView)

    override func awakeFromNib() {
        super.awakeFromNib()

        set(loading: true)
    }
}
