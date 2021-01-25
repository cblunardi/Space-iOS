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
    @IBOutlet private var headerStackView: UIStackView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var catalogButton: UIButton!
    @IBOutlet private var hintLabel: UILabel!

    private lazy var scrollViewZooming: CurrentValueSubject<Bool, Never> =
        .init(scrollView.isZooming)

    private(set) lazy var loadingView: AnimationView = makeLoadingView(in: view)

    override var prefersStatusBarHidden: Bool {
        scrollViewZooming.value
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind(viewModel: viewModel)
    }

    func bind(viewModel: MainViewModel) {
        bindImage(viewModel: viewModel)

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

        viewModel.hintLabelVisible
            .combineLatest(scrollViewZooming)
            .map { visible, zooming in visible && (zooming == false) }
            .map { $0 ? 1.0 : 0.0 }
            .assignWeakly(to: \.alpha, on: hintLabel, animationDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        hintLabel.text = viewModel.hintLabelTitle

        viewModel.load()
    }

    private func bindImage(viewModel: MainViewModel) {
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
                return .init(top: inset, left: .zero, bottom: inset, right: .zero)
            }
            .assignWeakly(to: \.scrollView.contentInset, on: self)
            .store(in: &subscriptions)
    }
}

private extension MainViewController {
    func configure() {
        scrollView.delegate = self

        scrollViewZooming
            .map { $0 ? 0.0 : 1.0 }
            .assignWeakly(to: \.alpha, on: headerStackView, animationDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        scrollViewZooming
            .map(!)
            .assignWeakly(to: \.isEnabled, on: panGestureRecognizer)
            .store(in: &subscriptions)

        scrollViewZooming
            .sink { [weak self] _ in self?.setNeedsStatusBarAppearanceUpdate() }
            .store(in: &subscriptions)
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
            self.scrollViewDidZoom(self.scrollView)

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

    @IBAction func showAboutPressed(_ sender: UIButton) {
        viewModel.showAboutPressed()
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

        guard scrollViewZooming.value != isZoomed else { return }
        scrollViewZooming.send(isZoomed)
    }
}
