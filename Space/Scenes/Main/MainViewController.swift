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
        // Do any additional setup after loading the view.
    }

    func bind(viewModel: MainViewModel) {
        subscriptions.removeAll()

        self.viewModel = viewModel

        viewModel.currentImage
            .receive(on: RunLoop.main)
            .assignWeakly(to: \.mainImageView.image, on: self)
            .store(in: &subscriptions)
    }
}
