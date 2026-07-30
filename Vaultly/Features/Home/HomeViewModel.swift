//
//  HomeViewModel.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 09.07.26.
//

import Foundation
import Observation

@MainActor
@Observable
final class HomeViewModel {
    enum ViewState {
        case loading
        case empty
        case loaded
        case error(String)
    }
    
    struct AmountSpentByCategory: Identifiable {
        let id: UUID
        let name: String
        let amount: Decimal
        let colorHex: Int
        var amountInDouble: Double { (amount as NSDecimalNumber).doubleValue }
    }
    
    private(set) var state: ViewState = .loading
    private(set) var netWorth: Decimal = .zero
    private(set) var monthlyIncome: Decimal = .zero
    private(set) var monthlyExpense: Decimal = .zero
    private(set) var amountSpentByCategory: [AmountSpentByCategory] = []
    private(set) var recentTransactions: [Transaction] = []
    
    var monthlyNet: Decimal { monthlyIncome - monthlyExpense }
    var totalSpent: Decimal { amountSpentByCategory.reduce(.zero) { $0 + $1.amount } }
    
    private let transactionRepo: TransactionRepositoryProtocol
    private let accountRepo: AccountRepositoryProtocol
    
    init(transactionRepo: TransactionRepositoryProtocol,
         accountRepo: AccountRepositoryProtocol) {
        self.transactionRepo = transactionRepo
        self.accountRepo = accountRepo
    }

    
    func load() {
        state = .loading
        
        do {
            let accounts = try accountRepo.all()
            let all = try transactionRepo.all()
            
            guard !all.isEmpty else {
                state = .empty
                return
            }
            
            netWorth = accounts.reduce(Decimal.zero) { $0 + $1.balance }
            let currentMonthTransactions = all.filter { Self.isCurrentMonth($0.date) }
            monthlyIncome = currentMonthTransactions.filter {$0.type == .income}.reduce(.zero) { $0 + $1.amount }
            monthlyExpense = currentMonthTransactions.filter {$0.type == .expense}.reduce(.zero) { $0 + $1.amount }
            amountSpentByCategory = Self.spendByCategory(currentMonthTransactions)
            recentTransactions = Array(all.prefix(5))
            
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    static func isCurrentMonth(_ date: Date, now: Date = .now, Calendar: Calendar = .current) -> Bool {
        Calendar.isDate(date, equalTo: now, toGranularity: .month)
    }
    
    static func spendByCategory(_ transactions: [Transaction]) -> [AmountSpentByCategory] {
        let noneID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        var totals: [UUID: (name: String, color: Int, amount: Decimal)] = [:]
        
        
        for t in transactions where t.type == .expense {
            let id = t.category?.id ?? noneID
            var entry = totals[id] ?? (t.category?.name ?? "Uncategorised",
                                       t.category?.colorHex ?? 0x9CB0A8, .zero)
            entry.amount += t.amount
            totals[id] = entry
        }
        
        return totals
            .map {
                AmountSpentByCategory(id: $0.key, name: $0.value.name,
                                      amount: $0.value.amount, colorHex: $0.value.color)
            }
            .sorted { $0.amount > $1.amount }
    }
}
