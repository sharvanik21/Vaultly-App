//
//  CurrencyFormatterTests.swift
//  VaultlyTests
//
//  Created by Sharvani Karrepu on 30.07.26.
//

import Testing
import Foundation
@testable import Vaultly

struct CurrencyFormatterTests {
    
    @Test("Formats INR using Indian digit grouping")
    func formatsINR() {
        let result = CurrencyFormatter.string(150_000, code: "INR")
        #expect(result.contains("₹"))
        #expect(result.contains("1,50,000"))
    }
    
    @Test("Formats EUR using European decimal style")
    func formatsEUR() {
        let result = CurrencyFormatter.string(3_200, code: "EUR")
        #expect(result.contains("€"))
        #expect(result.contains("3.200,00"))
    }
    
    @Test("Negative values are prefixed with a minus sign, not a plus")
    func signedNegative() {
        let result = CurrencyFormatter.signed(-50, code: "USD")
        #expect(result.hasPrefix("-"))
    }
    
    @Test("Positive values are prefixed with a plus sign")
    func signedPositive() {
        let result = CurrencyFormatter.signed(50, code: "USD")
        #expect(result.hasPrefix("+"))
    }
}
