extension Range where Bound: AdditiveArithmetic {
    func offset(by amount: Bound) -> Self {
        lowerBound + amount ..< upperBound + amount
    }
}

extension Range where Bound: Numeric {
    func mapped(by amount: Bound) -> Self {
        lowerBound * amount ..< upperBound * amount
    }
}
