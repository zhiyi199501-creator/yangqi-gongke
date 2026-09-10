import SwiftUI

struct InkQiView: View {
    var score: Int

    private var fill: CGFloat {
        CGFloat(min(max(score, 0), 100)) / 100
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20, paused: false)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let breath = 0.5 + 0.5 * sin(t * 1.35)
            Canvas { context, size in
                let pad: CGFloat = 3
                let maxR = min(size.width, size.height) / 2 - pad
                let cx = size.width / 2
                let sunR = maxR * (0.46 + 0.14 * fill) * (0.97 + 0.03 * breath)
                let glowR = min(maxR, sunR * 1.42)
                let rayOuter = min(maxR - 1, sunR + 5 + 4 * fill)

                var cy = size.height * (0.70 - 0.24 * fill)
                cy = min(max(cy, pad + glowR), size.height * 0.62)

                let sky = Path(ellipseIn: CGRect(
                    x: pad,
                    y: pad,
                    width: size.width - pad * 2,
                    height: size.height - pad * 2
                ))
                context.fill(sky, with: .color(InkTheme.seal.opacity(0.10 + 0.16 * fill)))

                let glow = Path(ellipseIn: CGRect(x: cx - glowR, y: cy - glowR, width: glowR * 2, height: glowR * 2))
                context.fill(glow, with: .color(InkTheme.sunGlow.opacity(0.35 + 0.45 * fill)))

                if fill > 0.12 {
                    for i in 0..<8 {
                        let angle = Double(i) / 8 * .pi * 2 + t * 0.15
                        var ray = Path()
                        let inner = sunR + 2
                        ray.move(to: CGPoint(x: cx + inner * cos(angle), y: cy + inner * sin(angle)))
                        ray.addLine(to: CGPoint(x: cx + rayOuter * cos(angle), y: cy + rayOuter * sin(angle)))
                        context.stroke(ray, with: .color(InkTheme.lamp.opacity(0.25 + 0.55 * fill)), lineWidth: 2)
                    }
                }

                let sun = Path(ellipseIn: CGRect(x: cx - sunR, y: cy - sunR, width: sunR * 2, height: sunR * 2))
                context.fill(sun, with: .color(InkTheme.lamp))

                let sparkle = Path(ellipseIn: CGRect(
                    x: cx - sunR * 0.42,
                    y: cy - sunR * 0.48,
                    width: sunR * 0.55,
                    height: sunR * 0.38
                ))
                context.fill(sparkle, with: .color(.white.opacity(0.45)))

                let hillHeight = size.height * 0.28
                let hill = Path(ellipseIn: CGRect(
                    x: size.width * 0.12,
                    y: size.height - hillHeight * 0.72,
                    width: size.width * 0.76,
                    height: hillHeight
                ))
                context.fill(hill, with: .color(InkTheme.seal.opacity(0.55 + 0.35 * fill)))
            }
        }
        .accessibilityHidden(true)
    }
}
