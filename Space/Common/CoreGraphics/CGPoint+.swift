import CoreGraphics

extension CGPoint {
    static func * (_ lhs: CGPoint, _ rhs: CGFloat) -> CGPoint {
        .init(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
