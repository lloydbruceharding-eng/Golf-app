//
//  Theme.swift
//  Skins
//
//  Casual, warm, fast. Golf-green accent and friendly rounded type.
//

import SwiftUI

extension Color {
    static let golfGreen = Color(red: 0.13, green: 0.55, blue: 0.30)
    static let golfGreenDark = Color(red: 0.08, green: 0.38, blue: 0.21)
    static let fairway = Color(red: 0.90, green: 0.96, blue: 0.90)
    static let sandHighlight = Color(red: 0.99, green: 0.85, blue: 0.45)
}

enum AppFont {
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// South African Rand formatting — whole numbers for clean, screenshot-ready cards.
enum Money {
    static func string(_ amount: Double) -> String {
        let rounded = (amount).rounded()
        let magnitude = abs(Int(rounded))
        let sign = rounded < 0 ? "-" : ""
        return "\(sign)R\(magnitude)"
    }

    static func signed(_ amount: Double) -> String {
        let rounded = amount.rounded()
        if rounded > 0 { return "+R\(Int(rounded))" }
        if rounded < 0 { return "-R\(abs(Int(rounded)))" }
        return "R0"
    }
}

/// A reusable circular avatar showing a player's initials.
struct PlayerAvatar: View {
    let player: Player
    var size: CGFloat = 34

    private var color: Color {
        let palette: [Color] = [.golfGreen, .blue, .orange, .purple, .pink, .teal]
        let index = abs(player.name.hashValue) % palette.count
        return palette[index]
    }

    var body: some View {
        Text(player.initials.isEmpty ? "?" : player.initials)
            .font(AppFont.rounded(size * 0.4, .bold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(color.gradient))
    }
}
