import Foundation
import SwiftData

/// A spending/income label such as Groceries, Rent or Salary.
@Model
final class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var symbolName: String
    var colorHex: Int

    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(
        id: UUID = UUID(),
        name: String,
        symbolName: String,
        colorHex: Int
    ) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
        self.colorHex = colorHex
    }
}
