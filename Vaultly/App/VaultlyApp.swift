import SwiftUI
import SwiftData

/// App entry point.
///
/// Responsibilities kept here are deliberately minimal:
///  - build the SwiftData container once
///  - gate the whole UI behind biometric auth (`AppLockManager`)
///  - apply the privacy screen so balances never appear in the app switcher
@main
struct VaultlyApp: App {

    @State private var lock = AppLockManager()
    private let container: ModelContainer

    init() {
        container = PersistenceController.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if lock.isUnlocked {
                    RootView()
                } else {
                    LockView(manager: lock)
                }
            }
            .privacyScreen()                 // blur when backgrounded
            .preferredColorScheme(.dark)
            .tint(Theme.Colors.accent)
        }
        .modelContainer(container)
    }
}
