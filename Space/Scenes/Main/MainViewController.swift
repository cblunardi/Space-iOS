import Combine
import UIKit

final class MainViewController: UIViewController, StoryboardLoadable, ViewModelOwner {
    typealias ViewModelType = MainViewModel

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var mainImageView: UIImageView!
    @IBOutlet private var mainImageViewAspectConstraint: NSLayoutConstraint!
    @IBOutlet private var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet private var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!

    var viewModel: MainViewModel!

    private var subscriptions: Set<AnyCancellable> = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

        guard subscriptions.isEmpty, viewModel != nil else { return }
        setupSubscriptions()
    }

    func bind(viewModel: MainViewModel) {
        self.viewModel = viewModel

        guard isViewLoaded else { return }
        setupSubscriptions()
    }

    private func setupSubscriptions() {
        subscriptions.removeAll()

        viewModel
            .currentImage
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.image,
                          on: mainImageView,
                          crossDissolveDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)

        viewModel
            .currentImage
            .map { $0?.size.aspectRatio }
            .replaceNil(with: 1.0)
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.mainImageViewAspectConstraint.constant, on: self)
            .store(in: &subscriptions)

        viewModel.currentImage
            .combineLatest(publisher(for: \.view.frame))
            .map { image, frame -> CGFloat in
                let imageSize = image?.size ?? .zero
                let imageHeight = frame.width / imageSize.aspectRatio
                return (frame.height - imageHeight) / 2.0
            }
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.scrollView.contentInset.top, on: self)
            .store(in: &subscriptions)

        viewModel.currentTitle
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.titleLabel.text, on: self)
            .store(in: &subscriptions)

        viewModel.currentSubtitle
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.subtitleLabel.text, on: self)
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
            scrollView.maximumZoomScale : scrollView.minimumZoomScale

        UIView.animate(withDuration: 0.5) {
            let tapLocation: CGPoint = self.tapGestureRecognizer.location(in: self.scrollView)

            let zoomedViewPort: CGRect = CGRect(center: tapLocation * zoomScale,
                                                size: self.scrollView.frame.size)

            self.scrollView.setZoomScale(zoomScale, animated: false)
            self.scrollView.scrollRectToVisible(zoomedViewPort, animated: false)
        }

        panGestureRecognizer.isEnabled = zoomScale == scrollView.minimumZoomScale
    }

    @IBAction func didRecognizePanGesture(_ sender: UIPanGestureRecognizer) {
        guard sender == panGestureRecognizer else { return }

        let panTranslation = panGestureRecognizer.translation(in: mainImageView).x
        guard panTranslation.isFinite else { return }

        viewModel.didRecognize(relativeTranslation: Double(panTranslation / mainImageView.frame.width)) 

        guard panGestureRecognizer.state == .ended else { return }
        viewModel.didFinishPanning()
    }
}

extension MainViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mainImageView
    }
}
