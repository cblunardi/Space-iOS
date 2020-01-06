import Combine
import UIKit

final class MainViewController: UIViewController, StoryboardLoadable, ViewModelOwner {
    typealias ViewModelType = MainViewModel

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var mainImageView: UIImageView!
    @IBOutlet private var mainImageViewAspectConstraint: NSLayoutConstraint!

    var viewModel: MainViewModel!

    private var subscriptions: Set<AnyCancellable> = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    func bind(viewModel: MainViewModel) {
        subscriptions.removeAll()

        self.viewModel = viewModel

        viewModel
            .currentImage
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.mainImageView.image, on: self)
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
    }
}

private extension MainViewController {
    func configure() {
        scrollView.delegate = self
    }

    @IBAction func didRecognizeTapGesture(_ sender: UITapGestureRecognizer) {
        let zoomScale: CGFloat = scrollView.zoomScale == scrollView.minimumZoomScale ?
            scrollView.maximumZoomScale : scrollView.minimumZoomScale

        let zoomedViewPort: CGRect = CGRect(center: sender.location(in: scrollView) * zoomScale,
                                            size: scrollView.frame.size)


        UIView.animate(withDuration: 0.5) {
            self.scrollView.setZoomScale(zoomScale, animated: false)

            if zoomScale != self.scrollView.minimumZoomScale {
                self.scrollView.scrollRectToVisible(zoomedViewPort, animated: false)
            }
        }
    }
}

extension MainViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mainImageView
    }
}
