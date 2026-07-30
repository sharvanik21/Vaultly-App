//
//  BudgetView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 10.07.26.
//

import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var context
    @State private var viewModel: BudgetViewModel?
    @State private var showAddBugetScreen: Bool = false
    @State private var editingBudget: Budget?
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    var body: some View {
        NavigationStack{
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                if let viewModel {
                    content(viewModel)
                } else {
                    ProgressView().tint(Theme.Colors.accent)
                }
            }
            .navigationTitle("Budgets")
            .toolbar {
                ToolbarItem(placement: .primaryAction){
                    Button {
                        showAddBugetScreen = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBugetScreen){
                AddBudgetView { budget in
                    viewModel?.add(budget)
                }
            }
            .sheet(item: $editingBudget) { budget in
                AddBudgetView(budget: budget) { updated in
                    viewModel?.update(updated)
                }
            }
        }
        .task {
            if viewModel == nil {
                viewModel = BudgetViewModel(transactionRepository: TransactionRepository(context: context), budgetRepository: BudgetRepository(context: context))
            }
            viewModel?.load()
        }
    }
    
    @ViewBuilder
    private func content(_ model: BudgetViewModel) -> some View {
        switch model.state {
        case .loading:
            ProgressView().tint(Theme.Colors.accent)
        case .empty:
            ContentUnavailableView {
                Label("No Budgets", systemImage: "tray")
            } description: {
                Text("Add Budgets for any Catergory")
            } actions: {
                Button("Add Budget") {
                    showAddBugetScreen = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.Colors.accent)
            }
        case .loaded(let budgets):
            VStack(spacing: 0) {
                budgetList(model, budgets: budgets) { id in
                    editingBudget = model.budget(withID: id)
                }
            }
        case .error(let message):
            ContentUnavailableView {
                Label("Something Went Wrong", systemImage: "exclamationmark.triangle.fill")
            } description: {
                Text(message)
            } actions: {
                Button("Retry"){
                    model.load()
                }
                .buttonStyle(.bordered)
                .tint(Theme.Colors.accent)
            }
        }
    }
    
    private func budgetList(_ model: BudgetViewModel, budgets: [BudgetProgress], onEdit: @escaping (UUID) -> Void) -> some View {
        List {
            SummaryHeader(model: model)
                .padding(.top, Theme.Spacing.sm)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 4, trailing: 0))
                .background(Theme.Colors.surfaceRaised, in: .rect(cornerRadius: Theme.Radius.md))

            ForEach(model.budgets){ budget in
                budgetCard(budget)
                    .budgetCard()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                    .contentShape(Rectangle())
                    .onTapGesture { onEdit(budget.id) }
            }
            .onDelete{ indexSet in
                for index in indexSet {
                    model.delete(id: budgets[index].id)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    private func barColor(for item: BudgetProgress) -> Color {
        if item.isLimitOver { return Theme.Colors.negative }
        if item.fraction >= 0.8 { return Theme.Colors.warning }
        return Theme.Colors.accent
    }
    
    private func iconBadge(budget: BudgetProgress) -> some View {
        let color = Color(hex: UInt(budget.categoryColor))
        return Image(systemName: budget.categoryIcon)
            .font(.headline)
            .foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.15), in: .circle)
    }
    
    private func budgetCard(_ budget: BudgetProgress) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm){
            HStack {
               iconBadge(budget: budget)
                Text(budget.categoryName)
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                Spacer()
                Text("\(CurrencyFormatter.string(budget.spent, code: currencyCode)) / \(CurrencyFormatter.string(budget.limit, code: currencyCode))")
                    .font(Theme.Typography.caption.monospacedDigit())
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.Colors.surfaceRaised)
                    Capsule()
                        .fill(barColor(for: budget))
                        .frame(width: geo.size.width * budget.fraction)
                }
            }
            .frame(height: 10)
            HStack {
                Text(budget.percentText)
                    .font(Theme.Typography.body)
                Spacer()
                Text(budget.isLimitOver
                                ? "Over by \(CurrencyFormatter.string(budget.spent - budget.limit, code: currencyCode))"
                                : "\(CurrencyFormatter.string(budget.remainingAmount, code: currencyCode)) left")
                .foregroundStyle(barColor(for: budget))
            }
            .foregroundStyle(barColor(for: budget))
        }
    }
}

private struct SummaryHeader: View {
    let model: BudgetViewModel
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm){
            HStack {
                Text("Spent this month")
                Spacer()
                Text("of \(CurrencyFormatter.string(model.totalBudget, code: currencyCode))")
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.Colors.textSecondary)
            
           Text("\(CurrencyFormatter.string(model.totalSpent, code: currencyCode))")
                .font(Theme.Typography.title)
                .foregroundStyle(Theme.Colors.textPrimary)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.Colors.surface)
                    Capsule()
                        .fill(barColor())
                        .frame(width: geo.size.width * model.totalFraction)
                }
            }
            .frame(height: 10)
            
            HStack {
                Spacer()
                Text(model.isLimitOver ? "Over by \(CurrencyFormatter.string(model.totalSpent - model.totalBudget, code: currencyCode))" : "\(CurrencyFormatter.string(model.totalRemainingAmount, code: currencyCode)) left")
                    .foregroundStyle(barColor())
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surfaceRaised, in: .rect(cornerRadius: Theme.Radius.md))
    }
    
     func barColor() -> Color {
        if model.isLimitOver { return Theme.Colors.negative }
        if model.totalFraction >= 0.8 { return Theme.Colors.warning }
        return Theme.Colors.accent
    }
}

extension View {
    func budgetCard() -> some View {
        self
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surface, in: .rect(cornerRadius: Theme.Radius.md))
    }
}


#Preview {
    BudgetView()
        .modelContainer(PersistenceController.preview())
        .preferredColorScheme(.dark)
}
