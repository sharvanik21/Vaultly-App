import Foundation
import SwiftData

/// Builds the single `ModelContainer` for the app.
///
/// Encryption at rest: the SwiftData store lives in the app sandbox, which iOS
/// encrypts via Data Protection when the device is locked. Enable the
/// "Data Protection" capability in Signing & Capabilities and the store inherits
/// `NSFileProtectionComplete`. For stronger at-rest encryption (e.g. data
/// readable only while the app is in the foreground) you would layer SQLCipher or
/// encrypt sensitive fields with a key kept in the Keychain / Secure Enclave.
enum PersistenceController {

    static let schema = Schema([
        Account.self,
        Transaction.self,
        Category.self,
        Budget.self
    ])

    @MainActor
    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            SampleData.seedIfNeeded(container.mainContext)
            return container
        } catch {
            // In production you'd surface this and offer a recovery path rather
            // than crash; for development a hard failure makes the cause obvious.
            fatalError("Unable to create ModelContainer: \(error)")
        }
    }

    /// A throwaway in-memory container for SwiftUI previews and unit tests.
    @MainActor
    static func preview() -> ModelContainer {
        let container = makeContainer(inMemory: true)
        SampleData.seedIfNeeded(container.mainContext, force: true)
        return container
    }
}
