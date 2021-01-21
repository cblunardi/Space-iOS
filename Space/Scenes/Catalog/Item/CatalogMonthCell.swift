import Combine
import UIKit

final class CatalogMonthCell: UICollectionViewCell, ViewModelOwner {
    static let reuseIdentifier = "CatalogMonthCell"

    private static let roundedMaskLayer: CALayer = makeRoundedMaskLayer()

    var viewModel: CatalogMonthViewModel!

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var containerStackView: UIStackView!

    private lazy var items: [UIView] = containerStackView
        .arrangedSubviews
        .compactMap { $0 as? UIStackView }
        .flatMap(\.arrangedSubviews)

    override func awakeFromNib() {
        super.awakeFromNib()

        let maskedLayer = Self.roundedMaskLayer
        items.forEach {
            $0.layer.mask = maskedLayer
        }
    }

    func bind(viewModel: CatalogMonthViewModel) {
        self.viewModel = viewModel

        label.text = viewModel.text

        items
            .enumerated()
            .forEach { $0.element.backgroundColor = viewModel.color(for: $0.offset) }
    }
}

private extension CatalogMonthCell {
    static func makeRoundedMaskLayer() -> CAShapeLayer {
        let layer: CAShapeLayer = .init()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 1, height: 1)).cgPath
        layer.fillColor = UIColor.white.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }
}
