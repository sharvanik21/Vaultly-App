//
//  SettingsView.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 20.07.26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {

    @AppStorage("currencyCode") private var currencyCode = "USD"
    
    @Environment(\.modelContext) private var context
    @State private var exportURL: URL?
    @State private var showingDeleteAlert: Bool = false
    @State private var model: SettingsViewModel?
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("PREFERENCES") {
                    HStack(spacing: Theme.Spacing.md) {
                        settingIcon("banknote.fill", color: Theme.Colors.positive)
                        Text("Currency")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Text(currencyCode)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
                
                Section("DATA") {
                    Button {
                        exportURL = model?.exportCSV()
                        
                    } label: {
                        HStack(spacing: Theme.Spacing.md){
                            settingIcon("square.and.arrow.up", color: Theme.Colors.accent)
                            Text("Export Data")
                                .font(Theme.Typography.headline)
                                .foregroundStyle(Theme.Colors.textPrimary)
                        }
                    }
                    
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack(spacing: Theme.Spacing.md) {
                            settingIcon("trash.fill", color: Theme.Colors.negative)
                            Text("Delete All Data")
                                .font(Theme.Typography.headline)
                                .foregroundStyle(Theme.Colors.negative)
                        }
                    }
                }
                
                Section("ABOUT") {
                    HStack(spacing: Theme.Spacing.md) {
                        settingIcon("info.circle.fill", color: Theme.Colors.blue)
                        Text("Version")
                            .foregroundStyle(Theme.Colors.textPrimary)
                        Spacer()
                        Text(appVersion)
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }
            }
        }
        
        .sheet(item: $exportURL) { url in
            ShareLink(item: url)
        }
        .alert("Delete All Data?", isPresented: $showingDeleteAlert){
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {model?.deleteAll()}
        } message: {
            Text("This permanently removes all transactions, budgets, categories, and accounts, and lets you choose your currency again. This can't be undone.")
        }
        
        .task {
            
            if model == nil {
                model = SettingsViewModel(transactionRepo: TransactionRepository(context: context),
                                          budgetRepo: BudgetRepository(context: context),
                                          accountRepo: AccountRepository(context: context),
                                          categoryRepo: CategoryRepository(context: context)
                )
            }
        }
    }
    
    private func settingsPicker<Option: Identifiable & Hashable>(
        _ title: String,
        icon: String,
        color: Color,
        selection: Binding<String>,
        options: [Option],
        label: @escaping (Option) -> String,
        tag:  @escaping (Option) -> String
    ) -> some View {
        Picker(selection: selection) {
            ForEach(options) { option in
                Text(label(option)).tag(tag(option))
            }
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                settingIcon(icon, color: color)
                Text(title)
                    .font(Theme.Typography.headline)
            }
        }
        .pickerStyle(.navigationLink)
    }
    
    private func settingIcon(_ symbolName: String, color: Color) -> some View {
        Image(systemName: symbolName)
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Theme.Colors.textPrimary)
            .frame(width: 30, height: 30)
            .background(color, in: .rect(cornerRadius: Theme.Spacing.sm))
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
