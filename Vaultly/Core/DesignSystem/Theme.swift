import SwiftUI

/// Centralised design tokens. Keeping colour, spacing, radius and type in one
/// place keeps the UI consistent and makes re-theming a one-file change.
enum Theme {

    enum Colors {
        static let accent        = Color(hex: 0x2E9E83)  
        static let accentSoft    = Color(hex: 0x4FB89C)
        static let background     = Color(hex: 0x0E1512)
        static let surface        = Color(hex: 0x18211D)
        static let surfaceRaised  = Color(hex: 0x202B26)
        static let textPrimary    = Color(hex: 0xF2F5F3)
        static let textSecondary  = Color(hex: 0x9CB0A8)
        static let positive       = Color(hex: 0x4ADE80)
        static let negative       = Color(hex: 0xF87171)
        static let warning        = Color(hex: 0xF59E0B)
        static let separator      = Color.white.opacity(0.08)
        static let purple         = Color(hex: 0xA78BFA)
        static let blue           = Color(hex: 0x60A5FA)
        static let green          = Color(hex: 0x4ADE80)
        static let amber          = Color(hex: 0xF59E0B)
        static let grey           = Color(hex: 0x333333)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xx1: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 14
        static let lg: CGFloat = 22
    }

    enum Typography {
        static let largeTitle = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let title      = Font.system(.title2,     design: .rounded, weight: .semibold)
        static let headline   = Font.system(.headline,   design: .rounded)
        static let body       = Font.system(.body,       design: .rounded)
        static let caption    = Font.system(.caption,    design: .rounded)
        static let mono       = Font.system(.body,       design: .monospaced)
    }
}

extension Color {
    /// Hex initialiser, e.g. `Color(hex: 0x2E9E83)`.
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8)  & 0xFF) / 255,
            blue:  Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
