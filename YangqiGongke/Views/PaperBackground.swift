import SwiftUI

struct PaperBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.96, blue: 0.88),
                    InkTheme.paper,
                    Color(red: 0.97, green: 0.99, blue: 0.94)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            Canvas { context, size in
                let sun = Path(ellipseIn: CGRect(
                    x: size.width * 0.58,
                    y: -size.height * 0.08,
                    width: size.width * 0.55,
                    height: size.width * 0.55
                ))
                context.fill(sun, with: .color(InkTheme.sunGlow.opacity(0.55)))
                let leaf = Path(ellipseIn: CGRect(
                    x: -size.width * 0.18,
                    y: size.height * 0.62,
                    width: size.width * 0.55,
                    height: size.width * 0.42
                ))
                context.fill(leaf, with: .color(InkTheme.seal.opacity(0.08)))
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
