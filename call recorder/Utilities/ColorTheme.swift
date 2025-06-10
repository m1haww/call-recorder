import SwiftUI

extension Color {
    static let primaryGreen = Color(hex: "#4AE54A")
    static let accentGreen = Color(hex: "#2ECC40")
    static let darkBackground = Color(hex: "#1A1A1A")
    static let cardBackground = Color(hex: "#2A2A2A")
    static let surfaceBackground = Color(hex: "#333333")
    
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "#B0B0B0")
    static let tertiaryText = Color(hex: "#808080")
    
    static let navyBlue = Color(hex: "#1B2A49")
    static let skyBlue = Color(hex: "#4AE54A")
    static let lightGrey = Color(hex: "#2A2A2A")
    static let mediumGrey = Color(hex: "#333333")
    static let darkGrey = Color(hex: "#B0B0B0")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
