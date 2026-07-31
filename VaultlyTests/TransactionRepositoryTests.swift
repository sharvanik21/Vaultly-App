//
//  TransactionRepositoryTests.swift
//  VaultlyTests
//
//  Created by Sharvani Karrepu on 30.07.26.
//

import Testing
import Foundation
import SwiftData
@testable import Vaultly

@MainActor
struct TransactionRepositoryTests {
    
    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(schema: PersistenceController.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PersistenceController.schema, configurations: configuration)
        return ModelContext(container)
    }
    
    @Test("Adding a transaction persists it and it comes back from all()")
    func addTransaction() throws {
        let repository = TransactionRepository(context: try makeContext())
        
        try repository.add(Transaction(amount: 42, type: .expense, note: "Coffee"))
        
        let all = try repository.all()
        #expect(all.count == 1)
        #expect(all.first?.note == "Coffee")
    }
    
    @Test("Deleting a transaction removes it from the store")
    func deleteTransaction() throws {
        let repository = TransactionRepository(context: try makeContext())
        
        let transaction = Transaction(amount: 42, type: .expense)
        try repository.add(transaction)
        #expect(try repository.all().count == 1)
        
        try repository.delete(transaction)
        #expect(try repository.all().count == 0)
    }
    
    @Test("all() returns transactions sorted with the most recent date first")
    func fetchSortedByDate() throws {
        let repository = TransactionRepository(context: try makeContext())
        
        try repository.add(Transaction(amount: 10, type: .expense, date: Date(timeIntervalSinceNow: -86_400)))
        try repository.add(Transaction(amount: 20, type: .expense, date: .now))
        
        let all = try repository.all()
        #expect(all.first?.amount == 20)
        #expect(all.last?.amount == 10)
    }
}
