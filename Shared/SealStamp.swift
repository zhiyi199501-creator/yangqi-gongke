import SwiftUI

struct SealStamp: View {
    var character: String
    var intensity: Double
    var size: CGFloat = 52

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(InkTheme.seal.opacity(0.12 + 0.22 * intensity))
                    .frame(width: size, height: size)
                Circle()
                    .fill(InkTheme.lamp)
                    .frame(
                        width: size * (0.28 + 0.42 * intensity),
                        height: size * (0.28 + 0.42 * intensity)
                    )
                    .offset(y: size * (0.16 - 0.28 * intensity))
                    .opacity(0.35 + 0.65 * max(intensity, 0.12))
                Ellipse()
                    .fill(InkTheme.seal.opacity(0.45 + 0.5 * intensity))
                    .frame(width: size * 0.72, height: size * 0.22)
                    .offset(y: size * 0.28)
            }
            .frame(width: size, height: size)

            if !character.trimmingCharacters(in: .whitespaces).isEmpty {
                Text(character)
                    .font(InkTheme.kaiti(size * 0.28))
                    .foregroundStyle(InkTheme.seal.opacity(intensity <= 0 ? 0.35 : 0.95))
            }
        }
        .frame(width: size, height: character.trimmingCharacters(in: .whitespaces).isEmpty ? size : size + 14)
        .accessibilityHidden(true)
    }
}
