import Foundation
import SwiftData

/// A single ledger entry. `amount` is always stored as a positive `Decimal`;
/// direction is carried by `type`, and `signedAmount` applies the sign. Storing
/// magnitude + direction separately avoids "is this number already negative?"
/// bugs throughout the codebase.
/// 
@Model
final class Transaction {
    @Attribute(.unique) var id: UUID
    var amount: Decimal
    private var typeRaw: String
    var note: String
    var date: Date

    var account: Account?
    var category: Category?

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    /// Positive for income, negative for expense.
    var signedAmount: Decimal {
        type == .income ? amount : -amount
    }

    init(
        id: UUID = UUID(),
        amount: Decimal,
        type: TransactionType,
        note: String = "",
        date: Date = .now,
        account: Account? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.amount = amount
        self.typeRaw = type.rawValue
        self.note = note
        self.date = date
        self.account = account
        self.category = category
    }
}
