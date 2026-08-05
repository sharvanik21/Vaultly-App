//
//  ProfileSetupViewModel.swift
//  Vaultly
//
//  Created by Sharvani Karrepu on 04.08.26.
//

import Foundation

@MainActor
@Observable
final class ProfileSetupViewModel {
    private let accountRepo: AccountRepositoryProtocol

    init(accountRepo: AccountRepositoryProtocol) {
        self.accountRepo = accountRepo
    }

    func createAccount(named name: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let account = Account(name: trimmedName.isEmpty ? "Main" : trimmedName, type: .checking)
        do {
            try accountRepo.add(account)
        } catch {
            print("Failed to create account: \(error)")
        }
    }
}
