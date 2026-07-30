import SwiftUI
internal import LocalAuthentication

/// The gate shown until the user authenticates. Triggers Face ID automatically on
/// appear, and offers a retry button if it fails.
struct LockView: View {
    let manager: AppLockManager

    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.lg) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(Theme.Colors.accent)

                VStack(spacing: Theme.Spacing.xs) {
                    Text("Vaultly")
                        .font(Theme.Typography.largeTitle)
                        .foregroundStyle(Theme.Colors.textPrimary)
                    Text("Your finances, locked down.")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }

                if case .failed(let message) = manager.state {
                    Text(message)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.negative)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button {
                    Task { await manager.authenticate() }
                } label: {
                    Label("Unlock", systemImage: unlockIcon)
                        .font(Theme.Typography.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.accent, in: .rect(cornerRadius: Theme.Radius.md))
                        .foregroundStyle(.white)
                }
                .disabled(manager.state == .authenticating)
                .padding(.top, Theme.Spacing.md)
            }
            .padding(Theme.Spacing.xl)
        }
        .task { await manager.authenticate() }
    }

    private var unlockIcon: String {
        switch manager.biometryType {
        case .faceID:  "faceid"
        case .touchID: "touchid"
        default:       "key.fill"
        }
    }
}

#Preview {
    LockView(manager: AppLockManager())
}
