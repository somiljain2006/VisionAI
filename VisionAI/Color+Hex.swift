import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hex.hasPrefix("#") ? String(hex.dropFirst()) : hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)

        self.init(
            red: Double((hexNumber & 0xFF0000) >> 16) / 255,
            green: Double((hexNumber & 0x00FF00) >> 8) / 255,
            blue: Double(hexNumber & 0x0000FF) / 255
        )
    }
}
