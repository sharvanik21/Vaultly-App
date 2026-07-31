//
//  HomeViewModelTests.swift
//  VaultlyTests
//
//  Created by Sharvani Karrepu on 31.07.26.
//

import Testing
import Foundation
import SwiftData
@testable import Vaultly

@MainActor
struct HomeViewModelTests {
    
    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(schema: PersistenceController.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PersistenceController.schema, configurations: configuration)
        return ModelContext(container)
    }
    
    @Test("Net Worth sums balance across every account")
    func netWorthCalculation() throws {
        let context = try makeContext()
        let transactionRepo = TransactionRepository(context: context)
        let accountRepo = AccountRepository(context: context)

        let checking = Account(name: "Checking", type: .checking)
        let savings = Account(name: "Savings", type: .savings)
        try accountRepo.add(checking)
        try accountRepo.add(savings)
        
        try transactionRepo.add(Transaction(amount: 1000, type: .income, account: checking))
        try transactionRepo.add(Transaction(amount: 200, type: .expense, account: checking))
        try transactionRepo.add(Transaction(amount: 500, type: .income, account: savings))
        
        let model = HomeViewModel(transactionRepo: transactionRepo, accountRepo: accountRepo)
        model.load()
        
        #expect(model.netWorth == 1300)
    }
    
    @Test("Monthly income and expense totals only include transactions from the current month")
    func monthlyTotals() throws {
        let context = try makeContext()
        let transactionRepo = TransactionRepository(context: context)
        let accountRepo = AccountRepository(context: context)
        
        let account = Account(name: "Main", type: .checking)
        try accountRepo.add(account)
        
        try transactionRepo.add(Transaction(amount: 4200, type: .income, date: .now, account: account))
        try transactionRepo.add(Transaction(amount: 150, type: .expense, date: .now, account: account))
        
        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        try transactionRepo.add(Transaction(amount: 999, type: .expense, date: lastMonth, account: account))
        
        let model = HomeViewModel(transactionRepo: transactionRepo, accountRepo: accountRepo)
        model.load()
        
        #expect(model.monthlyIncome == 4200)
        #expect(model.monthlyExpense == 150)
    }
}
