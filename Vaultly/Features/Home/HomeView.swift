//
//  HomeView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 09.07.26.
//

import SwiftUI
import SwiftData
import Charts

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @State private var model: HomeViewModel?
    @AppStorage("currencyCode") private var currencyCode = "USD"
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                if let model {
                    content(model)
                } else {
                    ProgressView().tint(Theme.Colors.accent)
                }
            }
            .navigationTitle("Overview")
        }
        .task {
            if model == nil {
                model = HomeViewModel(transactionRepo: TransactionRepository(context: context), accountRepo: AccountRepository(context: context))
            }
            model?.load()
        }
    }
    
    @ViewBuilder
    private func content(_ model: HomeViewModel) -> some View {
        switch model.state {
        case .loading:
            ProgressView().tint(Theme.Colors.accent)
        case .empty:
            ContentUnavailableView("Nothing to show yet",
                                   systemImage: "chart.line.uptrend.xyaxis",
                                   description: Text("Add a transaction and your overview will appear here."))
        case .error(let message):
            ContentUnavailableView {
                Label("Couldn't load overview", systemImage: "exclamationmark.triangle.fill")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { model.load() }.tint(Theme.Colors.accent)
            }
        case .loaded:
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    netWorthCard(model)
                    monthlyCashFlow(model)
                    spendingChart(model)
                    recentActiviyCard(model)
                }
                .padding(Theme.Spacing.md)
            }
            
        }
    }
    
    private func netWorthCard(_ model: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Net Worth")
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
            Text(CurrencyFormatter.string(model.netWorth, code: currencyCode))
                .font(Theme.Typography.largeTitle.monospacedDigit())
                .foregroundStyle(Theme.Colors.textPrimary)
            HStack {
                Image(systemName: model.monthlyNet >= 0 ? "arrow.up.right" : "arrow.down.right")
                Text("\(CurrencyFormatter.signed(model.monthlyNet, code: currencyCode)) this month")
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(model.monthlyNet >= 0 ? Theme.Colors.positive : Theme.Colors.negative)
        }
        .homeCard()
    }
    
    private func monthlyCashFlow(_ model: HomeViewModel) -> some View {
        HStack(spacing: Theme.Spacing.md) {
            statCard("Income", model.monthlyIncome, Theme.Colors.positive, "arrow.down.left")
            statCard("Expense", model.monthlyExpense, Theme.Colors.negative, "arrow.up.right")
        }
    }
    
    private func statCard(_ label: String, _ value: Decimal,
                          _ color: Color, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Image(systemName: icon)
                Text(label)
            }
            .font(Theme.Typography.caption)
            .foregroundStyle(Theme.Colors.textSecondary)
            Text(CurrencyFormatter.string(value,code: currencyCode))
                .font(Theme.Typography.title.monospacedDigit())
                .foregroundStyle(color)
                .lineLimit(1).minimumScaleFactor(0.7)
        }
        .homeCard()
    }
    
    private func spendingChart(_ model: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Spending this month")
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.textPrimary)
            Chart(model.amountSpentByCategory) { spentAmount in
                SectorMark(
                    angle: .value("Amount", spentAmount.amountInDouble),
                    innerRadius: .ratio(0.75),
                    angularInset: 0.5
                )
                .cornerRadius(4)
                .foregroundStyle(Color(hex: UInt(max(0, spentAmount.colorHex))))
            }
            .chartLegend(.hidden)
            .frame(height: 190)
            .overlay {
                VStack(spacing: 2) {
                    Text("Spent")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                    Text(CurrencyFormatter.string(model.totalSpent, code: currencyCode))
                        .font(Theme.Typography.headline.monospacedDigit())
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
            }
            
            ForEach(model.amountSpentByCategory) { spentAmount in
                HStack(spacing: Theme.Spacing.sm) {
                    Circle()
                        .fill(Color(hex: UInt(max(0, spentAmount.colorHex))))
                        .frame(width: 10, height: 10)
                    Text(spentAmount.name)
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Spacer()
                    Text(CurrencyFormatter.string(spentAmount.amount, code: currencyCode))
                        .font(Theme.Typography.body.monospacedDigit())
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
        }
        .homeCard()
    }
    
    private func recentActiviyCard(_ model: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("Recent Activity")
                .font(Theme.Typography.headline)
                .foregroundStyle(Theme.Colors.textPrimary)
            ForEach(model.recentTransactions) { transaction in
                TransactionRowView(transaction: transaction)
                    .listRowBackground(Theme.Colors.surface)
                if transaction.id != model.recentTransactions.last?.id {
                    divider
                        .padding(.leading, Theme.Spacing.xx1)
                }
            }
        }
        .homeCard()
    }
    
    private var divider: some View {
        Rectangle()
            .fill(Theme.Colors.separator)
            .frame(maxWidth: .infinity, maxHeight: 1)
    }
}

extension View {
    func homeCard() -> some View {
        self
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surfaceRaised, in: .rect(cornerRadius: Theme.Radius.md))
    }
}

