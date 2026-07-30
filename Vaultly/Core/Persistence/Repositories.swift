import Foundation
import SwiftData

/// Data access is funnelled through repository protocols rather than letting
/// views touch `ModelContext` directly. This:
///  - keeps SwiftData out of the UI layer
///  - lets every feature be unit-tested against a fake repository
///  - makes it cheap to swap the storage engine later
///
/// Repositories are `@MainActor` because the `mainContext` they use is bound to
/// the main actor. For heavy background work you'd introduce a `ModelActor`.

@MainActor
protocol TransactionRepositoryProtocol {
    func all() throws -> [Transaction]
    func recent(limit: Int) throws -> [Transaction]
    func add(_ transaction: Transaction) throws
    func update(_ transaction: Transaction) throws
    func delete(_ transaction: Transaction) throws
    func deleteAll() throws
}

@MainActor
protocol AccountRepositoryProtocol {
    func all() throws -> [Account]
    func add(_ account: Account) throws
    func delete(_ account: Account) throws
}

@MainActor
protocol CategoryRepositoryProtocol {
    func all() throws -> [Category]
    func add(_ category: Category) throws
}

@MainActor
protocol BudgetRepositoryProtocol {
    func all() throws -> [Budget]
    func add(_ budget: Budget) throws
    func update(_ budget: Budget) throws
    func delete(_ budget: Budget) throws
    func deleteAll() throws
}

// MARK: - SwiftData-backed implementations

@MainActor
struct TransactionRepository: TransactionRepositoryProtocol {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() throws -> [Transaction] {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func recent(limit: Int) throws -> [Transaction] {
        var descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func add(_ transaction: Transaction) throws {
        context.insert(transaction)
        try context.save()
    }

    /// `transaction` is an already-tracked SwiftData object (fetched, then
    /// mutated in place by the edit form), so persisting the change is just a
    /// save — there's nothing to re-insert.
    func update(_ transaction: Transaction) throws {
        try context.save()
    }

    func delete(_ transaction: Transaction) throws {
        context.delete(transaction)
        try context.save()
    }

    func deleteAll() throws {
        let items = try context.fetch(FetchDescriptor<Transaction>())
        for item in items { context.delete(item) }
        try context.save()
    }
}

@MainActor
struct AccountRepository: AccountRepositoryProtocol {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() throws -> [Account] {
        try context.fetch(
            FetchDescriptor<Account>(sortBy: [SortDescriptor(\.createdAt)])
        )
    }
    func add(_ account: Account) throws {
        context.insert(account)
        try context.save()
    }

    func delete(_ account: Account) throws {
        context.delete(account)
        try context.save()
    }
}

@MainActor
struct CategoryRepository: CategoryRepositoryProtocol {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }

    func all() throws -> [Category] {
        try context.fetch(
            FetchDescriptor<Category>(sortBy: [SortDescriptor(\.name)])
        )
    }
    func add(_ category: Category) throws {
        context.insert(category)
        try context.save()
    }
}

@MainActor
struct BudgetRepository: BudgetRepositoryProtocol {
    private let context: ModelContext
    init(context: ModelContext) { self.context = context }
    
    func all() throws -> [Budget] {
        try context.fetch(
            FetchDescriptor<Budget>(sortBy: [SortDescriptor(\.limit, order: .reverse)])
        )
    }
    
    func add(_ budget: Budget) throws {
        context.insert(budget)
        try context.save()
    }

    /// `budget` is an already-tracked SwiftData object, mutated in place by
    /// the edit form, so persisting the change is just a save.
    func update(_ budget: Budget) throws {
        try context.save()
    }

    func delete(_ budget: Budget) throws {
        context.delete(budget)
        try context.save()
    }
    
    func deleteAll() throws {
        let items = try context.fetch(FetchDescriptor<Budget>())
        for item in items { context.delete(item) }
        try context.save()
    }
}
