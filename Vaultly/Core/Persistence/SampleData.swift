import Foundation
import SwiftData

/// Seeds a fresh database with sensible default categories
///  Runs only when the store has no data (unless `force` is set for previews).
enum SampleData {

    @MainActor
    static func seedIfNeeded(_ context: ModelContext, force: Bool = false) {
        let existing = (try? context.fetch(FetchDescriptor<Category>())) ?? []
        guard force || existing.isEmpty else { return }

        let defaults: [(String, String, Int)] = [
            ("Salary",     "dollarsign.circle.fill", 0x4ADE80),
            ("Groceries",  "cart.fill",              0xF59E0B),
            ("Rent",       "house.fill",             0x60A5FA),
            ("Transport",  "car.fill",               0xA78BFA),
            ("Dining",     "fork.knife",             0xF87171),
            ("Utilities",  "bolt.fill",              0x38BDF8),
            ("Crypto",     "bitcoinsign.circle.fill",0xF7931A),
            ("Fitness",    "figure.run",             0xEC4899),
            ("Miscellaneous",  "ellipsis.circle.fill",    0x9CB0A8)
        ]
        
        let categories = defaults.map { Category(name: $0.0, symbolName: $0.1, colorHex: $0.2) }
        categories.forEach { context.insert($0) }

        try? context.save()
    }
}
