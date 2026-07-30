//
//  TransactionsRowView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 06.07.26.
//

import Foundation
import SwiftUI

struct TransactionRowView: View {
    
    @AppStorage("currencyCode") private var currencyCode = "USD"
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            iconBadge
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Uncategorised")
                    .font(Theme.Typography.headline)
                    .foregroundStyle(Theme.Colors.textPrimary)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(1)
                }

            }
            Spacer(minLength: Theme.Spacing.sm)
            Text(CurrencyFormatter.signed(transaction.signedAmount, code: currencyCode))
                .font(Theme.Typography.body.monospacedDigit())
                .foregroundStyle(transaction.type.tint)
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
    
    private var iconBadge: some View {
        let color = Color(hex: UInt(transaction.category?.colorHex ?? 0x9CB0A8))
        return Image(systemName: transaction.category?.symbolName ?? "questionmark.circle.fill")
            .font(.headline)
            .foregroundStyle(color)
            .frame(width: 40, height: 40)
            .background(color.opacity(0.15), in: .circle)
    }
}
