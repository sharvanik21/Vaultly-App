//
//  CurrencySetupView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 03.08.26.
//

import SwiftUI
import SwiftData

struct ProfileSetupView: View {
    @AppStorage("currencyCode") private var currencyCode = "USD"
    @AppStorage("hasSetCurrency") private var hasSetCurrency = false

    @Environment(\.modelContext) private var context

    @State private var selectedCode: String
    @State private var accountName: String = ""
    @State private var showingCurrencyList = false

    init() {
        let detected = Locale.current.currency?.identifier ?? "USD"
        let resolved = AppCurrency(rawValue: detected)?.rawValue ?? AppCurrency.usd.rawValue
        _selectedCode = State(initialValue: resolved)
    }

    private var selectedCurrency: AppCurrency {
        AppCurrency(rawValue: selectedCode) ?? .usd
    }

    private var isValid: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()

            Image(systemName: "banknote.fill")
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(Theme.Colors.accent)

            VStack(spacing: Theme.Spacing.sm) {
                Text("Let's set things up")
                    .font(Theme.Typography.title)
                    .foregroundStyle(Theme.Colors.textPrimary)

                Text("Choose your currency and name your account. Currency can't be changed later, so make sure it's right.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
            }

            VStack(spacing: Theme.Spacing.sm) {
                Button {
                    showingCurrencyList = true
                } label: {
                    HStack {
                        Text("Currency")
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Spacer()
                        Text(selectedCurrency.displayName)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                    .font(Theme.Typography.headline)
                    .padding()
                    .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.md))
                }

                HStack {
                    Text("Account name")
                        .foregroundStyle(Theme.Colors.textSecondary)
                    Spacer()
                    TextField("Enter your account name", text: $accountName)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
                .font(Theme.Typography.headline)
                .padding()
                .background(Theme.Colors.surface, in: RoundedRectangle(cornerRadius: Theme.Radius.md))
            }
            .padding(.horizontal, Theme.Spacing.lg)

            Spacer()

            Button {
                confirm()
            } label: {
                Text("Get started")
                    .font(Theme.Typography.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isValid ? Theme.Colors.accent : Theme.Colors.grey)
                    .foregroundStyle(Theme.Colors.background)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            }
            .disabled(!isValid)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.bottom, Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background.ignoresSafeArea())
        .sheet(isPresented: $showingCurrencyList) {
            CurrencyListPickerView(selectedCode: $selectedCode)
        }
    }

    private func confirm() {
        let trimmedName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        let account = Account(name: trimmedName.isEmpty ? "Main" : trimmedName, type: .checking)
        context.insert(account)
        try? context.save()

        currencyCode = selectedCode
        hasSetCurrency = true
    }
}

private struct CurrencyListPickerView: View {
    @Binding var selectedCode: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(AppCurrency.allCases) { currency in
                Button {
                    selectedCode = currency.rawValue
                    dismiss()
                } label: {
                    HStack {
                        Text(currency.displayName)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        if currency.rawValue == selectedCode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Theme.Colors.accent)
                        }
                    }
                }
                .listRowBackground(Theme.Colors.surface)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.Colors.background.ignoresSafeArea())
            .navigationTitle("Currency")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProfileSetupView()
        .preferredColorScheme(.dark)
}
