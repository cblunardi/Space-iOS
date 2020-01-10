import Combine
import UIKit

final class CatalogItemCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogItemCell"

    private var subscriptions: Set<AnyCancellable> = .init()

    var viewModel: CatalogItemViewModel!

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        subscriptions.removeAll()
    }

    func bind(viewModel: CatalogItemViewModel) {
        subscriptions.removeAll()

        self.viewModel = viewModel

        label.text = viewModel.text

        viewModel
            .image
            .assignWeakly(to: \.image,
                          on: imageView,
                          crossDissolveDuration: UIC.Anims.imageTransitionDuration)
            .store(in: &subscriptions)
    }
}
