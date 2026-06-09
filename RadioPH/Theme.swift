import SwiftUI
import UIKit

enum Theme {
    static let ivory = dynamic(
        light: UIColor(red: 0.965, green: 0.941, blue: 0.890, alpha: 1),
        dark: UIColor(red: 0.075, green: 0.055, blue: 0.045, alpha: 1)
    )
    static let espresso = dynamic(
        light: UIColor(red: 0.235, green: 0.125, blue: 0.078, alpha: 1),
        dark: UIColor(red: 0.965, green: 0.90, blue: 0.80, alpha: 1)
    )
    static let surface = dynamic(
        light: .white,
        dark: UIColor(red: 0.14, green: 0.105, blue: 0.085, alpha: 1)
    )
    static let control = Color(red: 0.235, green: 0.125, blue: 0.078)
    static let onDark = Color(red: 0.965, green: 0.941, blue: 0.890)
    static let brass = Color(red: 0.74, green: 0.48, blue: 0.13)
    static let ember = Color(red: 1.0, green: 0.44, blue: 0.08)
    static let signalRed = dynamic(
        light: UIColor(red: 0.78, green: 0.18, blue: 0.12, alpha: 1),
        dark: UIColor(red: 1.0, green: 0.34, blue: 0.27, alpha: 1)
    )
    static let dialBlack = Color(red: 0.08, green: 0.075, blue: 0.065)
    static let brushedBrass = LinearGradient(
        colors: [
            Color(red: 0.72, green: 0.50, blue: 0.26),
            Color(red: 0.96, green: 0.78, blue: 0.48),
            Color(red: 0.69, green: 0.44, blue: 0.20)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}
