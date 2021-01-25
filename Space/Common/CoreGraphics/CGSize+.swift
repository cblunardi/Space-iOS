import CoreGraphics

extension CGSize {
    var aspectRatio: CGFloat { width / height }
}

extension CGSize {
    static func / (_ lhs: CGSize, _ rhs: CGFloat) -> CGSize {
        .init(width: lhs.width / rhs, height: lhs.height / rhs)
    }
}
