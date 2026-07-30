//
//  TransactionsViewModel.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 06.07.26.
//

import Foundation

@MainActor
@Observable

final class TransactionsViewModel {
    enum ViewState {
        case loading
        case empty
        case error(String)
        case loaded([TransactionSection])
    }
    
    struct Summary {
        var income: Decimal
        var expense: Decimal
        var net: Decimal { income - expense }
        static let zero = Summary(income: 0, expense: 0)
    }

    private(set) var state: ViewState = .loading
    private(set) var summary: Summary = .zero
    
    private let repository: TransactionRepositoryProtocol
    
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }
    
    func load()  {
        state = .loading
        do {
            let transactions = try repository.all()
            summary = Self.summarize(transactions)
            state = transactions.isEmpty ? .empty : .loaded(Self.group(transactions))
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func add(_ transaction: Transaction) {
        do {
            try repository.add(transaction)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func update(_ transaction: Transaction) {
        do {
            try repository.update(transaction)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func delete(_ transaction: Transaction) {
        do {
            try repository.delete(transaction)
            load()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    
    // MARK: - helpers (easy to test)
    static func summarize(_ transactions: [Transaction]) -> Summary {
        var income = Decimal.zero
        var expense = Decimal.zero
        for t in transactions {
            switch t.type {
            case .income:  income += t.amount
            case .expense: expense += t.amount
            }
        }
        return Summary(income: income, expense: expense)
    }
    
    static func group(_ transactions: [Transaction]) -> [TransactionSection] {
        let calendar = Calendar.current
        let byDay = Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
        return byDay.keys.sorted(by: >).map { day in
            TransactionSection(
                id: day,
                title: sectionTitle(for: day, calendar: calendar),
                transactions: (byDay[day] ?? []).sorted { $0.date > $1.date }
            )
        }
    }
    
    private static func sectionTitle(for day: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(day)     { return "Today" }
        if calendar.isDateInYesterday(day) { return "Yesterday" }
        return day.formatted(.dateTime.weekday(.wide).month().day())
    }
}


/// A day's worth of transactions, for a `List` section.
struct TransactionSection: Identifiable {
    let id: Date
    let title: String
    let transactions: [Transaction]
    
    var dayTotal: Decimal {
        transactions.reduce(Decimal.zero) {
            $0 + $1.signedAmount
        }
    }
}
