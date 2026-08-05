//
//  SettingsViewModel.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 20.07.26.
//

import Foundation

@MainActor
@Observable
final class SettingsViewModel {
    private let transactionRepo: TransactionRepositoryProtocol
    private let budgetRepo: BudgetRepositoryProtocol
    private let accountRepo: AccountRepositoryProtocol
    private let categoryRepo: CategoryRepositoryProtocol
    
    init(transactionRepo: TransactionRepositoryProtocol, budgetRepo: BudgetRepositoryProtocol, accountRepo: AccountRepositoryProtocol, categoryRepo: CategoryRepositoryProtocol) {
        self.transactionRepo = transactionRepo
        self.budgetRepo = budgetRepo
        self.categoryRepo = categoryRepo
        self.accountRepo = accountRepo
    }

    func deleteAll() {
        do {
            try transactionRepo.deleteAll()
            try budgetRepo.deleteAll()
            try accountRepo.deleteAll()
        } catch {
            print("Delete failed: \(error)")
        }
        
        UserDefaults.standard.set(false, forKey: "hasSetCurrency")
    }
    
    func exportCSV() -> URL? {
        guard let transactions = try? transactionRepo.all() else { return nil }

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"

        var lines = ["Date,Type,Amount,Category,Account,Note"]
        for t in transactions {
            let row = [
                df.string(from: t.date),
                t.type.rawValue,
                "\(t.signedAmount)",
                t.category?.name ?? "Uncategorised",
                t.account?.name ?? "",
                t.note
            ].map(escapeCSV).joined(separator: ",")
            lines.append(row)
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Vaultly-Export.csv")
        try? lines.joined(separator: "\n").write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func escapeCSV(_ field: String) -> String {
        guard field.contains(",") || field.contains("\"") || field.contains("\n") else { return field }
        return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}

enum AutoLockDelay: String, CaseIterable, Identifiable {
    case immediately, oneMinute, fiveMinutes, fifteenMinutes, oneHour
    var id: String { rawValue }

    var label: String {
        switch self {
        case .immediately:    "Immediately"
        case .oneMinute:      "After 1 minute"
        case .fiveMinutes:    "After 5 minutes"
        case .fifteenMinutes: "After 15 minutes"
        case .oneHour:        "After 1 hour"
        }
    }

    var seconds: TimeInterval {
        switch self {
        case .immediately:    0
        case .oneMinute:      60
        case .fiveMinutes:    300
        case .fifteenMinutes: 900
        case .oneHour:        3600
        }
    }
}

enum AppCurrency: String, CaseIterable, Identifiable {
    case usd = "USD", eur = "EUR", gbp = "GBP", inr = "INR"
    case jpy = "JPY", cny = "CNY", cad = "CAD", aud = "AUD"
    case chf = "CHF", sgd = "SGD", aed = "AED"

    var id: String { rawValue }

    var displayName: String {
        let symbol = Locale.current.localizedString(forCurrencyCode: rawValue) ?? rawValue
        return "\(rawValue) (\(symbol))"
    }
}

extension AppCurrency {
    /// Falls back to USD when the locale's currency isn't one of the supported ones.
    static func resolved(from locale: Locale) -> AppCurrency {
        guard let code = locale.currency?.identifier, let currency = AppCurrency(rawValue: code) else {
            return .usd
        }
        return currency
    }
}
