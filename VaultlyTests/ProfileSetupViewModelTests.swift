//
//  ProfileSetupViewModelTests.swift
//  VaultlyTests
//
//  Created by Sharvani Karrepu on 04.08.26.
//

import Testing
import Foundation
import SwiftData
@testable import Vaultly

@Suite(.serialized)
@MainActor
struct ProfileSetupViewModelTests {
    private func makeContext() throws -> ModelContext {
        let configuration = ModelConfiguration(schema: PersistenceController.schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: PersistenceController.schema, configurations: configuration)
        return ModelContext(container)
    }

    @Test("Creating an account trims whitespace from the entered name")
    func createsAccountWithTrimmedName() throws {
        let repo = AccountRepository(context: try makeContext())
        let viewModel = ProfileSetupViewModel(accountRepo: repo)

        viewModel.createAccount(named: "  My Wallet  ")

        let accounts = try repo.all()
        #expect(accounts.count == 1)
        #expect(accounts.first?.name == "My Wallet")
    }

    @Test("An empty or whitespace-only name falls back to 'Main'")
    func fallsBackToMainWhenNameIsBlank() throws {
        let repo = AccountRepository(context: try makeContext())
        let viewModel = ProfileSetupViewModel(accountRepo: repo)

        viewModel.createAccount(named: "   ")

        let accounts = try repo.all()
        #expect(accounts.first?.name == "Main")
    }
}
