# Vaultly

![Swift](https://img.shields.io/badge/Swift-5-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS18-blue)
![SwiftData](https://img.shields.io/badge/SwiftData-Local-green)
![Platform](https://img.shields.io/badge/Platform-iOS18+-black)

**A privacy-first personal finance manager for iOS.** Track transactions, set budgets, and see where your money goes — all stored securely on your device, never on a server.

Built with **SwiftUI** and **SwiftData** to showcase modern native iOS development practices.

<p align="center">
  <img src="Vaultly/Screenshots/home.png" width="240" />
    <img src="Vaultly/Screenshots/recentactivity.png" width="240" />
  <img src="Vaultly/Screenshots/transactions.png" width="240" />
  <img src="Vaultly/Screenshots/budgets.png" width="240" />
</p>

---

# Why Vaultly?

I'm particularly interested in fintech, and wanted a portfolio project that reflected that — a personal finance app forces real decisions around precision (money math), security (sensitive data at rest and in the app switcher), and data modeling, not just UI polish.

Vaultly was built to demonstrate how I architect and develop a production-quality SwiftUI application using modern Apple frameworks.

The project focuses on more than just features—it showcases:

- Feature-first MVVM architecture
- Repository pattern with dependency injection
- SwiftData persistence
- Modern SwiftUI state management
- Local-first privacy and security
- Reusable design system
- Clean, testable, and maintainable code

---

## Features

### Home

- Net worth overview
- Monthly income and expense summary
- Interactive spending-by-category donut chart built with Swift Charts

### Transactions

- Grouped-by-day transaction history
- Daily totals
- Add, edit, and delete transactions
- Category and account tagging

### Budgets

- Weekly, monthly, and yearly budgets
- Live progress indicators
- Smart budget colors
  - 🟢 Under 80%
  - 🟠 Between 80% and 100%
  - 🔴 Over budget
 
 ### Multi-Currency

Choose from 11 major currencies.

Amounts automatically reformat throughout the app using each currency's native formatting style.

Examples:

- ₹ 1,50,000.00
- € 3.200,00
- $ 2,499.99 

### Privacy & Security

- Face ID / Touch ID authentication
- Automatic device passcode fallback
- Privacy screen to blur sensitive data in the iOS app switcher

### Data Ownership

- Export all transactions as CSV
- Delete all data with confirmation
- Everything remains stored locally on your device

---

## Tech Stack

| Area | Technology |
|------|-----------|
| Language | Swift 5 |
| UI | SwiftUI |
| Persistence | SwiftData |
| Charts | Swift Charts |
| Security | LocalAuthentication, Keychain |
| Architecture | MVVM, Repository Pattern |
| Testing | Swift Testing |
| Minimum target | iOS 18+, Xcode 16+ |
| IDE | Xcode 16+ |

---

# Architecture

Vaultly follows a **feature-first MVVM architecture** combined with the **Repository pattern**.

Each feature (Home, Transactions, Budgets, Settings) owns its views, view models, repositories, and business logic, allowing features to evolve independently while remaining easy to maintain and test.

```
                 SwiftUI Views
                        │
                        ▼
                  View Models
                        │
                        ▼
             Repository Protocols
                        │
                        ▼
              SwiftData Persistence
```              

A few deliberate design decisions:

Project structure:

```
Vaultly/
├── App/
│   ├── App Entry
│   ├── Authentication Gate
│   └── Model Container
│
├── Core/
│   ├── DesignSystem/
│   ├── Persistence/
│   ├── Security/
│   └── Utilities/
│
├── Models/
│
└── Features/
    ├── Home/
    ├── Transactions/
    ├── Budgets/
    ├── Settings/
    └── Lock/
```

# Design Decisions

### Feature-First Architecture

Keeping related views, view models, repositories, and models together makes each feature easier to understand, extend, and test independently.

### Repository Pattern

Repositories abstract SwiftData behind protocols, allowing view models to remain persistence-agnostic.

This keeps business logic independent from the persistence layer while enabling dependency injection and unit testing.

### Dependency Injection

Dependencies are injected into view models through repository protocols rather than being created internally, making the application easier to test and maintain.

### Decimal Instead of Double

Financial values require exact precision.

Using `Decimal` avoids floating-point rounding errors that can occur with `Double`.

### Currency Formatting

Users choose their preferred currency independently from device locale.

Each currency is rendered using its canonical formatting style to ensure consistent financial presentation.

### AppStorage vs SwiftData

- `@AppStorage` stores lightweight user preferences.

- SwiftData stores structured financial data.

Each persistence mechanism is used where it fits best.

### Concurrency

Data access is performed on the `@MainActor`, with repositories and view models isolated accordingly. Since `SwiftData`'s `ModelContext` is thread-confined, this approach avoids cross-actor context-passing issues while keeping the implementation simple and predictable.

For the scale of this application, the main actor provides more than enough performance. If the app were to support write-heavy tasks such as CSV imports or background sync, introducing a dedicated background `ModelActor` would be the recommended evolution.

---

## Testability

Vaultly is built with testability as a core design principle. The Repository pattern and dependency injection decouple business logic from the persistence layer, allowing repositories and view models to be tested independently.

Tests are written using **Swift Testing** (instead of XCTest) and execute against a real in-memory `SwiftData` `ModelContainer` rather than mocks. This approach validates actual persistence behavior while keeping tests fast, deterministic, and isolated.

| Test Suite | Coverage |
| --- | --- |
| `CurrencyFormatterTests` | Locale-aware currency formatting (INR, EUR) and correct positive/negative amount formatting |
| `BudgetViewModelTests` | Budget progress calculation, over-budget clamping, remaining balance, and category/period-based spending |
| `TransactionRepositoryTests` | Creating, deleting, and fetching transactions with deterministic sorting using an in-memory `ModelContainer` |
| `HomeViewModelTests` | Net worth aggregation across accounts and current-month income and expense summaries |

Current test coverage focuses on business logic and the data layer. UI-specific behavior, such as biometric authentication, the privacy overlay, and form validation, is planned for future iterations (see the Roadmap).

---

# Security

Vaultly is built with a local-first approach.

- Financial data never leaves the device.
- Authentication uses Face ID or Touch ID through `LocalAuthentication`.
- Device passcode is used automatically when biometrics are unavailable.
- Sensitive information is blurred in the app switcher to protect user privacy.

---

# Getting Started

Clone the repository

```bash
git clone https://github.com/sharvanik21/Vaultly.git
```

Open the project

```
Vaultly.xcodeproj
```

Requirements

- Xcode 16+
- iOS 18+

Build and run on a simulator or physical device.

The app launches with an empty ledger—simply create an account and start tracking your finances.

---

## Roadmap

- Account management
- Category management
- Recurring transactions
- CSV import
- CloudKit sync
- Widgets
- App Intents & Siri Shortcuts
- Expanded UI and snapshot testing

---

# Author

**Sharvani Karrepu**

iOS Engineer

- LinkedIn: https://linkedin.com/in/sharvanikarrepu
- GitHub: https://github.com/sharvanik21
