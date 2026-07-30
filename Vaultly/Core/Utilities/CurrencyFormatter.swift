import Foundation

/// Money is formatted from `Decimal`, never `Double`.
///
/// Binary floating point can't represent values like 0.10 exactly, which leads
/// to cent-level rounding errors that are unacceptable in a finance app. We use
/// `Decimal` everywhere money is stored or computed and only convert to a string
/// at the very edge, here.
enum CurrencyFormatter {
    
    private static var currencyCode: String {
        UserDefaults.standard.string(forKey: "currencyCode") ?? "USD"
    }

    private static func locale(for code: String) -> Locale {
        switch code {
        case "USD": Locale(identifier: "en_US")
        case "EUR": Locale(identifier: "de_DE")
        case "GBP": Locale(identifier: "en_GB")
        case "INR": Locale(identifier: "en_IN")
        case "JPY": Locale(identifier: "ja_JP")
        case "CNY": Locale(identifier: "zh_CN")
        case "CAD": Locale(identifier: "en_CA")
        case "AUD": Locale(identifier: "en_AU")
        case "CHF": Locale(identifier: "de_CH")
        case "SGD": Locale(identifier: "en_SG")
        case "AED": Locale(identifier: "ar_AE")
        default:    Locale.current
        }
    }

    /// e.g. `$1,250.00`
    static func string(_ amount: Decimal, code: String = "USD") -> String {
        amount.formatted(.currency(code: code).locale(locale(for: code)))
    }

    /// Always shows an explicit sign, e.g. `+$50.00` / `-$12.30`.
    static func signed(_ amount: Decimal, code: String = "USD") -> String {
        let prefix = amount < 0 ? "-" : "+"
        return prefix + abs(amount).formatted(.currency(code: code).locale(locale(for: code)))
    }

    /// Compact form for tight spaces, e.g. `$12.4K`, `$1.2M`.
    static func compact(_ amount: Decimal, code: String = "USD") -> String {
        let value = (amount as NSDecimalNumber).doubleValue
        let symbol = "$"
        switch abs(value) {
        case 1_000_000...:
            return "\(symbol)\((value / 1_000_000).formatted(.number.precision(.fractionLength(1))))M"
        case 1_000...:
            return "\(symbol)\((value / 1_000).formatted(.number.precision(.fractionLength(1))))K"
        default:
            return string(amount)
        }
    }
}
