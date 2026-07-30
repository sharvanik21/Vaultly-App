import Foundation
import SwiftData

/// A spending limit for a category over a period.
@Model
final class Budget {
    @Attribute(.unique) var id: UUID
    var limit: Decimal
    private var periodRaw: String
    var category: Category?

    var period: BudgetPeriod {
        get { BudgetPeriod(rawValue: periodRaw) ?? .monthly }
        set { periodRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        limit: Decimal,
        period: BudgetPeriod = .monthly,
        category: Category? = nil
    ) {
        self.id = id
        self.limit = limit
        self.periodRaw = period.rawValue
        self.category = category
    }
}
