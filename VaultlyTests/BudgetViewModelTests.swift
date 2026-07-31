//
//  BudgetViewModelTests.swift
//  VaultlyTests
//
//  Created by Sharvani Karrepu on 30.07.26.
//

import Testing
import Foundation
@testable import Vaultly

@MainActor
struct BudgetViewModelTests {

    @Test("Progress fraction and percent text reflect spend against limit")
    func progressCalculation(){
        let progress = BudgetProgress(
                    id: UUID(), categoryName: "Dining", categoryIcon: "fork.knife",
                    categoryColor: 0xF87171, limit: 200, spent: 100
                )
        #expect(progress.fraction == 0.5)
        #expect(progress.percentText == "50%")
        #expect(progress.isLimitOver == false)
    }
    
    @Test("Spending past the limit marks the budget as over, with fraction clamped at 1")
    func budgetExceeded() {
        let progress = BudgetProgress(
            id: UUID(), categoryName: "Dining", categoryIcon: "fork.knife",
            categoryColor: 0xF87171, limit: 100, spent: 150
        )
        #expect(progress.isLimitOver == true)
        #expect(progress.fraction == 1.0)
    }
    
    @Test("Remaining amount goes negative once spend exceeds the limit")
    func remainingAmount() {
        let underBudget = BudgetProgress(
            id: UUID(), categoryName: "Dining", categoryIcon: "fork.knife",
            categoryColor: 0xF87171, limit: 200, spent: 50
        )
        #expect(underBudget.remainingAmount == 150)
        
        let overBudget = BudgetProgress(
            id: UUID(), categoryName: "Dining", categoryIcon: "fork.knife",
            categoryColor: 0xF87171, limit: 100, spent: 150
        )
        #expect(overBudget.remainingAmount == -50)
    }

    @Test("spent(for:in:) only counts expense transactions in the matching category and period")
    func spentFiltersCorrectly() {
        let dining = Category(name: "Dining", symbolName: "fork.knife", colorHex: 0xF87171)
        let groceries = Category(name: "Groceries", symbolName: "cart.fill", colorHex: 0xF59E0B)
        let budget = Budget(limit: 200, period: .monthly, category: dining)
        
        let transactions = [
            Transaction(amount: 50, type: .expense, date: .now, category: dining),
            Transaction(amount: 30, type: .income, date: .now, category: dining),         // wrong type
            Transaction(amount: 40, type: .expense, date: .now, category: groceries),     // wrong category
            Transaction(amount: 20, type: .expense, date: .distantPast, category: dining) // wrong period
        ]
        
        let spent = BudgetViewModel.spent(for: budget, in: transactions)
        #expect(spent == 50)
    }
    
    @Test("Monthly, weekly, and yearly budgets all count a transaction dated today")
    func isInCurrentPeriodForNow() {
        let now = Date.now
        #expect(BudgetViewModel.isInCurrentPeriod(now, period: .monthly, now: now))
        #expect(BudgetViewModel.isInCurrentPeriod(now, period: .weekly, now: now))
        #expect(BudgetViewModel.isInCurrentPeriod(now, period: .yearly, now: now))
    }
    
    @Test("Every period excludes a transaction from a year ago")
    func isInCurrentPeriodExcludesLastYear() {
        let now = Date.now
        let lastYear = Calendar.current.date(byAdding: .year, value: -1, to: now)!
        #expect(!BudgetViewModel.isInCurrentPeriod(lastYear, period: .monthly, now: now))
        #expect(!BudgetViewModel.isInCurrentPeriod(lastYear, period: .weekly, now: now))
        #expect(!BudgetViewModel.isInCurrentPeriod(lastYear, period: .yearly, now: now))
    }
}
