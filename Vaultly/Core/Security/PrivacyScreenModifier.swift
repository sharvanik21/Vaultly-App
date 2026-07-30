import SwiftUI
import UIKit

/// Obscures sensitive content whenever the app is not active.
///
/// When iOS backgrounds an app it captures a snapshot for the app switcher. For a
/// finance app that snapshot would leak balances. This covers the UI the moment
/// the scene stops being active, so the snapshot shows only a lock.
///
/// This has to be a dedicated `UIWindow`, not a same-hierarchy `ZStack` overlay:
/// SwiftUI `.sheet`/`.fullScreenCover` content is presented as a separate
/// `UIViewController` stacked above the presenting view in UIKit terms, so an
/// overlay living inside that presenting view's own hierarchy sits *underneath*
/// the sheet and never covers it. A sibling window with a higher `windowLevel`
/// sits above everything in the scene — sheets, covers, and alerts included —
/// because window-level ordering wins over view-controller z-ordering.
@MainActor
final class PrivacyOverlayWindow {
    private var window: UIWindow?

    func show() {
        guard window == nil,
              let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first
        else { return }

        let overlay = UIWindow(windowScene: scene)
        overlay.windowLevel = .alert + 1
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = .clear
        let hosting = UIHostingController(rootView: PrivacyOverlayContent())
        hosting.view.backgroundColor = .clear
        overlay.rootViewController = hosting
        overlay.isHidden = false
        window = overlay
    }

    func hide() {
        window?.isHidden = true
        window = nil
    }
}

private struct PrivacyOverlayContent: View {
    var body: some View {
        Theme.Colors.background
            .overlay {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Theme.Colors.accent)
            }
            .ignoresSafeArea()
    }
}

struct PrivacyScreenModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase
    @State private var overlay = PrivacyOverlayWindow()

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    overlay.hide()
                } else {
                    overlay.show()
                }
            }
    }
}

extension View {
    func privacyScreen() -> some View { modifier(PrivacyScreenModifier()) }
}
