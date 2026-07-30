import Foundation
import SwiftData

/// A place money lives: a bank account, cash, a credit card, etc.
@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    private var typeRaw: String
    var currencyCode: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction] = []

    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .checking }
        set { typeRaw = newValue.rawValue }
    }

    /// Derived from its transactions, so it can never drift out of sync with the
    /// ledger. Fine for a personal app; for very large datasets you'd cache this.
    var balance: Decimal {
        transactions.reduce(Decimal.zero) { $0 + $1.signedAmount }
    }

    init(
        id: UUID = UUID(),
        name: String,
        type: AccountType,
        currencyCode: String = "USD",
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.typeRaw = type.rawValue
        self.currencyCode = currencyCode
        self.createdAt = createdAt
    }
}
