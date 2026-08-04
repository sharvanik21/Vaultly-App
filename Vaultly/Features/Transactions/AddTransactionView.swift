//
//  AddTransactionView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 06.07.26.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Account.createdAt) private var accounts: [Account]
    
    @State private var amountText = ""
    @State private var type: TransactionType = .expense
    @State private var note = ""
    @State private var date = Date.now
    @State private var selectedCategory: Category?

    /// When set, the form edits this transaction in place instead of creating
    /// a new one.
    private let existingTransaction: Transaction?
    let onSave: (Transaction) -> Void

    init(transaction: Transaction? = nil, onSave: @escaping (Transaction) -> Void) {
        self.existingTransaction = transaction
        self.onSave = onSave
        if let transaction {
            _amountText = State(initialValue: "\(transaction.amount)")
            _type = State(initialValue: transaction.type)
            _note = State(initialValue: transaction.note)
            _date = State(initialValue: transaction.date)
            _selectedCategory = State(initialValue: transaction.category)
        }
    }

    private var amount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }
    
    private var currencySymbol: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        return f.currencySymbol
    }
    
    private var isValid: Bool { amount != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    VStack(spacing: Theme.Spacing.md) {
                        HStack {
                            Text(currencySymbol)
                                .font(Theme.Typography.title.monospaced())
                                .foregroundStyle(Theme.Colors.textSecondary)
                            TextField("0.00", text: $amountText)
                                .keyboardType(.decimalPad)
                                .font(Theme.Typography.title.monospaced())
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .onChange(of: amountText) { _, newValue in
                                    amountText = formatAmount(newValue)
                                }
                            
                        }
                        .padding()
                        .background(Theme.Colors.surface, in: .rect(cornerRadius: Theme.Radius.md))
                        
                        transactionTypeSegment
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                
                
                Section("Details") {
                    Picker("Category", selection: $selectedCategory){
                        ForEach(categories) { category in
                            Label(category.name, systemImage: category.symbolName)
                                .tag(Optional(category))
                        }
                    }
                    
                    if let account = accounts.first {
                        HStack {
                            Text("Account")
                            Spacer()
                            Text(account.name)
                                .foregroundStyle(Theme.Colors.accent)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Note (optional)", text: $note)
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
                .listRowBackground(Theme.Colors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .navigationTitle(existingTransaction == nil ? "New Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() } .disabled(!isValid)
                }
            }
            .onAppear {
                guard existingTransaction == nil else { return }
                selectedCategory = selectedCategory ?? categories.first
            }
        }
    }
    
    private func save() {
        guard let amount else { return }
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let account = accounts.first
        
        if let existingTransaction {
            existingTransaction.amount = amount
            existingTransaction.type = type
            existingTransaction.note = trimmedNote
            existingTransaction.date = date
            existingTransaction.account = account
            existingTransaction.category = selectedCategory
            onSave(existingTransaction)
        } else {
            let transaction = Transaction(
                amount: amount,
                type: type,
                note: trimmedNote,
                date: date,
                account: account,
                category: selectedCategory
            )
            onSave(transaction)
        }
        dismiss()
    }
    
    private func formatAmount(_ input: String) -> String {
        var seenDecimal = false
        return input.filter { character in
            if character.isNumber { return true }
            if character == "." || character == "," {
                if seenDecimal { return false }
                seenDecimal = true
                return true
            }
            return false
        }
    }
    
    private var transactionTypeSegment: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases) { option in
                Button {
                    type = option
                } label: {
                    Text(option.label)
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.sm)
                        .foregroundStyle(type == option ? .white : Theme.Colors.textSecondary)
                        .background {
                            if type == option {
                                RoundedRectangle(cornerRadius: Theme.Radius.sm)
                                    .fill(Theme.Colors.accent)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                }
        }
        .background(Theme.Colors.surface, in: .rect(cornerRadius: Theme.Radius.sm))
    }
       
}
