import SwiftUI

/// Whether a transaction adds to or subtracts from a balance.
enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var label: String {
        switch self {
        case .income:  "Income"
        case .expense: "Expense"
        }
    }

    var systemImage: String {
        switch self {
        case .income:  "arrow.down.left.circle.fill"
        case .expense: "arrow.up.right.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .income:  Theme.Colors.positive
        case .expense: Theme.Colors.negative
        }
    }
}

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case checking
    case savings
    case cash
    case credit
    case investment

    var id: String { rawValue }

    var label: String {
        switch self {
        case .checking:   "Checking"
        case .savings:    "Savings"
        case .cash:       "Cash"
        case .credit:     "Credit Card"
        case .investment: "Investment"
        }
    }

    var systemImage: String {
        switch self {
        case .checking:   "building.columns.fill"
        case .savings:    "banknote.fill"
        case .cash:       "wallet.bifold.fill"
        case .credit:     "creditcard.fill"
        case .investment: "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .checking:   Color(hex: 0x60A5FA)
        case .savings:    Color(hex: 0x4ADE80)
        case .cash:       Color(hex: 0xF59E0B)
        case .credit:     Color(hex: 0xA78BFA)
        case .investment: Color(hex: 0x38BDF8)
        }
    }
}

enum BudgetPeriod: String, Codable, CaseIterable, Identifiable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var label: String {
        switch self {
        case .weekly:  "Weekly"
        case .monthly: "Monthly"
        case .yearly:  "Yearly"
        }
    }
}
