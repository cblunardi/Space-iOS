import UIKit

final class AcknowledgementsViewController: UIViewController, StoryboardLoadable, ViewModelOwner {
    var viewModel: AcknowledgementsViewModel!

    @IBOutlet private var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        bind(viewModel: viewModel)
    }

    func bind(viewModel: AcknowledgementsViewModel) {
        title = viewModel.title

        textView.text = viewModel.text
    }
}
