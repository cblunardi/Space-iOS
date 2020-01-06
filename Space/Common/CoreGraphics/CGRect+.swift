import CoreGraphics

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin: CGPoint = .init(x: center.x - size.width / 2,
                                    y: center.y - size.height / 2)
        self.init(origin: origin, size: size)
    }
}
