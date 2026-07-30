import Foundation
internal import LocalAuthentication
import Observation

/// Drives the biometric lock gate for the whole app.
///
/// Uses `.deviceOwnerAuthentication`, which means Face ID / Touch ID with an
/// automatic passcode fallback — so the app is still usable on devices without
/// biometrics, or after too many failed attempts.
@MainActor
@Observable
final class AppLockManager {

    enum State: Equatable {
        case locked
        case authenticating
        case unlocked
        case failed(String)
    }

    private(set) var state: State = .locked

    var isUnlocked: Bool { state == .unlocked }

    private let reason = "Unlock Vaultly to view your finances"

    func authenticate() async {
        guard state != .unlocked else { return }
        state = .authenticating

        let context = LAContext()
        context.localizedFallbackTitle = "Enter Passcode"

        var policyError: NSError?
        let policy: LAPolicy = .deviceOwnerAuthentication
        guard context.canEvaluatePolicy(policy, error: &policyError) else {
            state = .failed(policyError?.localizedDescription ?? "Authentication unavailable")
            return
        }

        do {
            let success = try await context.evaluatePolicy(policy, localizedReason: reason)
            state = success ? .unlocked : .failed("Authentication failed")
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func lock() { state = .locked }

    /// Used to pick the right icon on the lock screen.
    var biometryType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        return context.biometryType
    }
}
