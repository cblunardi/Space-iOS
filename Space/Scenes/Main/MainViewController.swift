import Combine
import Lottie
import UIKit

final class MainViewController: UIViewController, StoryboardLoadable, ViewModelOwner, LoadableView {
    typealias ViewModelType = MainViewModel

    var viewModel: MainViewModel!
    private var subscriptions: Set<AnyCancellable> = .init()

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var mainImageView: UIImageView!
    @IBOutlet private var mainImageViewAspectConstraint: NSLayoutConstraint!
    @IBOutlet private var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var catalogButton: UIButton!

    private(set) lazy var loadingView: AnimationView = makeLoadingView(in: view)

    override var prefersStatusBarHidden: Bool {
        scrollView.isZooming
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind(viewModel: viewModel)
    }

    func bind(viewModel: MainViewModel) {
        subscriptions.removeAll()

        viewModel
            .currentImage
            .assignWeakly(to: \.image,
                          on: mainImageView,
                          crossDissolveDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        viewModel
            .currentImage
            .map { $0?.size.aspectRatio }
            .replaceNil(with: 1.0)
            .assignWeakly(to: \.mainImageViewAspectConstraint.constant, on: self)
            .store(in: &subscriptions)

        viewModel
            .currentImage
            .map { $0 == nil }
            .removeDuplicates()
            .assignWeakly(to: \.isLoading, on: self, animationDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        viewModel.currentImage
            .combineLatest(publisher(for: \.view.frame))
            .map { image, frame -> UIEdgeInsets in
                let imageSize: CGSize = image?.size ?? .init(width: 1, height: 1)
                let imageHeight: CGFloat = frame.width / imageSize.aspectRatio
                let inset: CGFloat = (frame.height - imageHeight) / 2.0
                return .init(top: inset,  left: .zero,  bottom: inset,  right: .zero)
            }
            .assignWeakly(to: \.scrollView.contentInset, on: self)
            .store(in: &subscriptions)

        viewModel.currentTitle
            .assignWeakly(to: \.titleLabel.text, on: self)
            .store(in: &subscriptions)

        viewModel.currentSubtitle
            .assignWeakly(to: \.subtitleLabel.text, on: self)
            .store(in: &subscriptions)

        viewModel.catalogButtonVisible
            .map(!)
            .assignWeakly(to: \.isHidden, on: catalogButton, animationDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        viewModel.load()
    }
}

private extension MainViewController {
    func configure() {
        titleLabel.text = .none
        subtitleLabel.text = .none
        scrollView.delegate = self
    }

    @IBAction func didRecognizeTapGesture(_ sender: UITapGestureRecognizer) {
        guard sender == tapGestureRecognizer else { return }

        let zoomScale: CGFloat = scrollView.zoomScale == scrollView.minimumZoomScale ?
            scrollView.averageZoomScale : scrollView.minimumZoomScale

        UIView.animate(withDuration: 0.5) {
            let tapLocation: CGPoint = self.tapGestureRecognizer.location(in: self.scrollView)

            let zoomedViewPort: CGRect = CGRect(center: tapLocation * zoomScale,
                                                size: self.scrollView.frame.size)

            self.scrollView.setZoomScale(zoomScale, animated: false)

            guard zoomScale != self.scrollView.minimumZoomScale else { return }
            self.scrollView.scrollRectToVisible(zoomedViewPort, animated: false)
        }
    }

    @IBAction func didRecognizePanGesture(_ sender: UIPanGestureRecognizer) {
        guard sender == panGestureRecognizer else { return }

        let panTranslation = panGestureRecognizer.translation(in: mainImageView).x
        guard panTranslation.isFinite else { return }

        viewModel.didRecognize(relativeTranslation: Double(panTranslation / mainImageView.frame.width)) 

        guard panGestureRecognizer.state == .ended else { return }
        viewModel.didFinishPanning()
    }

    @IBAction func showCatalogPressed(_ sender: UIButton) {
        viewModel.showCatalogPressed()
    }
}

private extension UIScrollView {
    var averageZoomScale: CGFloat { (minimumZoomScale + maximumZoomScale) / 2}
}

extension MainViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mainImageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let isZoomed = scrollView.zoomScale != scrollView.minimumZoomScale
        panGestureRecognizer.isEnabled = isZoomed == false

        UIView.animate(withDuration: UIC.Anims.imageTransitionDuration) {
            self.titleLabel.alpha = isZoomed ? 0 : 1
            self.subtitleLabel.alpha = isZoomed ? 0 : 1
            self.catalogButton.alpha = isZoomed ? 0 : 1
            self.catalogButton.isUserInteractionEnabled = isZoomed == false
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
