import Foundation

struct Formatters {
    static let epicDateFormatter: DateFormatter = buildEPICDateFormatter()
    static let epicParameterNumberFormatter: NumberFormatter = buildEPICParameterNumberFormatter()

    private init() {}
}
