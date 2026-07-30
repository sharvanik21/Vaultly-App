//
//  TransactionView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 06.07.26.
//

import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var context
    @State private var showingAdd = false
    @State private var editingTransaction: Transaction?
    @State private var viewModel: TransactionsViewModel?
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
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .primaryAction){
                    Button {
                        showingAdd = true
                    } label : {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add transaction")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTransactionView { newTransaction in
                    viewModel?.add(newTransaction)
                }
            }
            .sheet(item: $editingTransaction) { transaction in
                AddTransactionView(transaction: transaction) { updated in
                    viewModel?.update(updated)
                }
            }
        }
        .task {
            if viewModel == nil {
                let repository = TransactionRepository(context: context)
                viewModel = TransactionsViewModel(repository: repository)
            }
            viewModel?.load()
        }
    }
    
    @ViewBuilder
    private func content(_ model: TransactionsViewModel) -> some View {
        switch model.state {
        case .loading:
            ProgressView().tint(Theme.Colors.accent)
        case .loaded(let sections):
                VStack(spacing: 0) {
                    transactionsList(model, sections: sections, currencyCode: currencyCode) { transaction in
                        editingTransaction = transaction
                    }
                }
        case .empty:
            ContentUnavailableView {
                Label {
                    Text("No transactions")
                } icon: {
                    Image(systemName: "tray")
                        .font(.system(size: 24))
                }
            } description: {
                Text("Add your income or expense to get started.")
            } actions: {
                Button("Add Transaction") {
                    showingAdd = true
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.Colors.accent)
            }
        case .error(let message):
            ContentUnavailableView {
                Label {
                    Text("Something Went Wrong")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                }
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
}

private func transactionsList(_ model: TransactionsViewModel,
                              sections: [TransactionSection],
                              currencyCode: String,
                              onEdit: @escaping (Transaction) -> Void) -> some View {
    List {
        SummaryHeader(summary: model.summary)
            .padding(.top, Theme.Spacing.sm)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Theme.Colors.surfaceRaised, in: .rect(cornerRadius: Theme.Radius.md))

        ForEach(sections) { section in
            Section {
                ForEach(section.transactions) { transaction in
                    TransactionRowView(transaction: transaction)
                        .listRowBackground(Theme.Colors.surface)
                        .contentShape(Rectangle())
                        .onTapGesture { onEdit(transaction) }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        model.delete(section.transactions[index])
                    }
                }
            } header : {
                HStack {
                    Text(section.title)
                    Spacer()
                    Text(CurrencyFormatter.signed(section.dayTotal, code: currencyCode))
                        .monospacedDigit()
                }
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
    }
    .listStyle(.insetGrouped)
    .scrollContentBackground(.hidden)
}

/// Income / expense / net card shown above the list.
private struct SummaryHeader: View {
    let summary: TransactionsViewModel.Summary
    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md){
            stat("Income", summary.income, Theme.Colors.positive)
            divider
            stat("Expense", summary.expense, Theme.Colors.negative)
            divider
            stat("Net", summary.net, summary.net >= 0 ? Theme.Colors.positive : Theme.Colors.negative)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.surfaceRaised, in: .rect(cornerRadius: Theme.Radius.md))
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Theme.Colors.separator)
            .frame(width: 1, height: 32)
    }
    
    private func stat(_ label: String, _ value: Decimal, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            Text(CurrencyFormatter.string(value, code: currencyCode))
                .font(Theme.Typography.headline.monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TransactionsView()
        .modelContainer(PersistenceController.preview())
        .preferredColorScheme(.dark)
}
