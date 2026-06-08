import SwiftUI

enum AppPalette {
    static let white = Color(hex: 0xFFFFFF)
    static let background = Color(hex: 0xF7FBF2)
    static let surface = Color(hex: 0xFFFFFF)
    static let surfaceAlt = Color(hex: 0xEFF7E6)
    static let divider = Color(hex: 0xDCE8CC)

    static let accentDark = Color(hex: 0x4D7C0F)
    static let accent = Color(hex: 0x84CC16)
    static let accentLight = Color(hex: 0xA3E635)
    static let accentSoft = Color(hex: 0xE7F8C8)

    static let blue = Color(hex: 0x2563EB)
    static let blueDark = Color(hex: 0x1E3A8A)
    static let blueSoft = Color(hex: 0xDBE7FF)

    static let textPrimary = Color(hex: 0x16210B)
    static let textSecondary = Color(hex: 0x556048)
    static let textMuted = Color(hex: 0x8A957C)

    static let green = Color(hex: 0x2E8B57)
    static let red = Color(hex: 0xC1392B)
    static let amber = Color(hex: 0xE0A23A)

    static let accentGradient: [Color] = [accent, blue]
}

extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}
