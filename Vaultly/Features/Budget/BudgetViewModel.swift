//
//  BudgetViewModel.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 10.07.26.
//

import Foundation
import SwiftData

@MainActor
@Observable
final class BudgetViewModel {
    enum ViewState {
        case loading
        case empty
        case error(String)
        case loaded([BudgetProgress])
    }
    
    private(set) var state: ViewState = .loading
    
    private let transactionRepository: TransactionRepository
    private let budgetRepository: BudgetRepository
    var budgets: [BudgetProgress] = []
    var totalBudget: Decimal = 0
    var totalSpent: Decimal = 0
    private var allBudgets: [Budget] = []
    
    var totalFraction: Double {
        let rawValue: Double = (totalSpent as NSDecimalNumber).doubleValue / (totalBudget as NSDecimalNumber).doubleValue
        return min(max(rawValue, 0), 1)
    }
    
    var totalRemainingAmount: Decimal {
        totalBudget - totalSpent
    }
    
    var isLimitOver: Bool {
        totalSpent > totalBudget 
    }
    
    init(transactionRepository:  TransactionRepository, budgetRepository: BudgetRepository) {
        self.transactionRepository = transactionRepository
        self.budgetRepository = budgetRepository
    }
    
    func load()  {
        state = .loading
        
        do {
            allBudgets = try budgetRepository.all()
            let transactions = try transactionRepository.all()
            
            if allBudgets.isEmpty{
                state = .empty
                return
            }
            
            budgets = allBudgets.map { budget in
                let spent = Self.spent(for: budget, in: transactions)
                
                return BudgetProgress(id: budget.id,
                                      categoryName: budget.category?.name ?? "Uncategorized",
                                      categoryIcon: budget.category?.symbolName ?? "questionmark.circle.fill",
                                      categoryColor: budget.category?.colorHex ?? 0x9CB0A8,
                                      limit: budget.limit,
                                      spent: spent)
            }
            .sorted { $0.fraction > $1.fraction }
            
            totalBudget = allBudgets.reduce(Decimal.zero){ $0 + $1.limit }
            totalSpent = budgets.reduce(Decimal.zero){ $0 + $1.spent }
            
            state = .loaded(budgets)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func add(_ budget: Budget) {
        do {
            try budgetRepository.add(budget)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func update(_ budget: Budget) {
        do {
            try budgetRepository.update(budget)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// The view only holds `BudgetProgress` (a display projection), so this
    /// resolves back to the actual `Budget` model for editing.
    func budget(withID id: UUID) -> Budget? {
        allBudgets.first { $0.id == id }
    }

    func delete(id: UUID) {
        guard let budget = allBudgets.first(where: { $0.id == id }) else { return }
        do {
            try budgetRepository.delete(budget)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    static func spent(for budget: Budget, in transaction: [Transaction]) -> Decimal {
        guard let categoryID = budget.category?.id else { return 0 }
        return transaction
            .filter{ $0.type == .expense}
            .filter{ $0.category?.id == categoryID}
            .filter{ isInCurrentPeriod($0.date, period: budget.period)}
            .reduce(Decimal.zero){$0 + $1.amount}
    }
    
    static func isInCurrentPeriod(
        _ date: Date,
        period: BudgetPeriod,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Bool {
        switch period {
        case .weekly:  calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .monthly: calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .yearly:  calendar.isDate(date, equalTo: now, toGranularity: .year)
        }
    }
}

struct BudgetProgress: Identifiable {
    let id: UUID
    let categoryName: String
    let categoryIcon: String
    let categoryColor: Int
    let limit: Decimal
    let spent: Decimal
    
    var remainingAmount: Decimal {
        limit - spent
    }
    
    var isLimitOver: Bool {
        spent > limit
    }
    
    var fraction: Double {
        guard limit > 0 else { return 0 }
        let rawValue: Double = (spent as NSDecimalNumber).doubleValue / (limit as NSDecimalNumber).doubleValue
        return min(max(rawValue, 0), 1)
    }
    
    var percentText: String {
        guard limit > 0 else { return "0%" }
        let percent = (spent as NSDecimalNumber).doubleValue / (limit as NSDecimalNumber).doubleValue * 100
        return "\(Int(percent))%"
    }
}
