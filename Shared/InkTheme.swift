import SwiftUI

enum InkTheme {
    /// 晨露底，带着一点新叶的青。
    static let paper = Color(red: 0.933, green: 0.976, blue: 0.953)
    /// 卡片里的浅薄荷底，给输入和芯片。
    static let paperDeep = Color(red: 0.843, green: 0.953, blue: 0.902)
    static let card = Color.white
    /// 园中深色
    static let ink = Color(red: 0.075, green: 0.263, blue: 0.220)
    static let inkSoft = Color(red: 0.357, green: 0.561, blue: 0.498)
    /// 嫩叶
    static let seal = Color(red: 0.090, green: 0.780, blue: 0.522)
    static let sealWash = Color(red: 0.090, green: 0.780, blue: 0.522).opacity(0.14)
    static let line = Color(red: 0.090, green: 0.780, blue: 0.522).opacity(0.22)
    /// 朝阳，只给主动作
    static let lamp = Color(red: 1.0, green: 0.690, blue: 0.125)
    static let sunGlow = Color(red: 1.0, green: 0.878, blue: 0.541)

    static let cardRadius: CGFloat = 22
    static let chipRadius: CGFloat = 14

    static var display: Font {
        kaiti(34)
    }

    static var title: Font {
        kaiti(22)
    }

    static var cardTitle: Font {
        .system(.headline, design: .rounded, weight: .semibold)
    }

    static var body: Font {
        .system(.body, design: .rounded)
    }

    static var caption: Font {
        .system(.caption, design: .rounded)
    }

    static var score: Font {
        .system(size: 62, weight: .semibold, design: .rounded)
    }

    static func kaiti(_ size: CGFloat) -> Font {
        .custom("STKaiti", size: size)
    }

    static func cardShadow(_ radius: CGFloat = 16) -> some View {
        RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
            .fill(card)
            .shadow(color: seal.opacity(0.14), radius: radius, y: 8)
    }
}
