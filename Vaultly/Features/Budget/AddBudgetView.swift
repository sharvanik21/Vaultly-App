//
//  AddBudgetView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 17.07.26.
//

import SwiftUI
import SwiftData

struct AddBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var allBudgets: [Budget]
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    @State private var budgetLimit = ""
    @State private var selectedCategory: Category?
    @State private var selectedBudgetPeriod: BudgetPeriod?

    /// When set, the form edits this budget in place instead of creating a
    /// new one.
    private let existingBudget: Budget?
    var onSaveBudget: (Budget) -> Void

    init(budget: Budget? = nil, onSaveBudget: @escaping (Budget) -> Void) {
        self.existingBudget = budget
        self.onSaveBudget = onSaveBudget
        if let budget {
            _budgetLimit = State(initialValue: "\(budget.limit)")
            _selectedCategory = State(initialValue: budget.category)
            _selectedBudgetPeriod = State(initialValue: budget.period)
        }
    }

    private var amount: Decimal? {
        let normalized = budgetLimit.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return value
    }
    
    /// A category (or "no category") can only have one budget per period —
    /// otherwise the same spend gets checked against two limits and double
    /// counted in the total. `existingBudget` is excluded so editing a
    /// budget without changing its category/period doesn't flag itself.
    private var isDuplicate: Bool {
        allBudgets.contains { candidate in
            candidate.id != existingBudget?.id &&
            candidate.category?.id == selectedCategory?.id &&
            candidate.period == (selectedBudgetPeriod ?? .monthly)
        }
    }

    private var isValid: Bool { amount != nil && !isDuplicate }
    
    private var currencySymbol: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        return f.currencySymbol
    }
    
    var body: some View {
        NavigationStack{
            Form {
                Section("Limit"){
                    HStack(spacing: Theme.Spacing.sm) {
                        Text(currencySymbol)
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        TextField("0.00", text: $budgetLimit)
                            .keyboardType(.decimalPad)
                            .font(Theme.Typography.title.monospaced())
                            .foregroundStyle(Theme.Colors.textPrimary)
                    }
                    .padding()
                    .listRowInsets(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
                    .background(Theme.Colors.surface, in: .rect(cornerRadius: Theme.Radius.md))
                    
                    .listRowBackground(Color.clear)
                }
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
              
                
              
                
                Section("DETAILS"){
                    Picker("Category", selection: $selectedCategory){
                        Text("none").tag(Optional<Category>.none)
                        ForEach(categories){ category in
                            Label(category.name, systemImage: category.symbolName)
                                .tag(Optional(category))
                        }
                    }
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .tint(Theme.Colors.accent)
                    Picker("Period", selection: $selectedBudgetPeriod){
                        ForEach(BudgetPeriod.allCases){ period in
                            Text("\(period.label)")
                                .tag(period)
                        }
                    }
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .tint(Theme.Colors.accent)

                    if isDuplicate {
                        Text("A budget for this category and period already exists. Edit that one instead of creating a duplicate.")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(Theme.Colors.negative)
                    }
                }
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textSecondary)
                .listRowBackground(Theme.Colors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background)
            .navigationTitle(existingBudget == nil ? "New Budget" : "Edit Budget")
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
                guard existingBudget == nil else { return }
                selectedBudgetPeriod = selectedBudgetPeriod ?? .monthly
                selectedCategory = selectedCategory ?? categories.first
            }
        }
       
    }
    
    private func save() {
        guard let amount else { return }
        if let existingBudget {
            existingBudget.limit = amount
            existingBudget.period = selectedBudgetPeriod ?? .monthly
            existingBudget.category = selectedCategory
            onSaveBudget(existingBudget)
        } else {
            let budget = Budget(limit: amount,
                                period: selectedBudgetPeriod ?? .monthly,
                                category: selectedCategory)
            onSaveBudget(budget)
        }
        dismiss()
    }
}
