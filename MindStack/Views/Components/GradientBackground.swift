import SwiftUI

struct GradientBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#020617"),
                        Color(hex: "#0B1121"),
                        Color(hex: "#101F22")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(AppColors.primary.opacity(0.08))
                    .frame(width: proxy.size.width * 1.35, height: proxy.size.width * 1.35)
                    .blur(radius: 80)
                    .offset(x: -proxy.size.width * 0.35, y: -proxy.size.height * 0.28)

                Circle()
                    .fill(AppColors.purple.opacity(0.06))
                    .frame(width: proxy.size.width * 1.20, height: proxy.size.width * 1.20)
                    .blur(radius: 90)
                    .offset(x: proxy.size.width * 0.35, y: proxy.size.height * 0.32)

                GridOverlay()
                    .opacity(0.08)
                    .blendMode(.screen)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .ignoresSafeArea()
    }
}

private struct GridOverlay: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            let line = Path { p in
                for x in stride(from: 0, through: size.width, by: spacing) {
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0, through: size.height, by: spacing) {
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
            }
            context.stroke(line, with: .color(AppColors.primary.opacity(0.25)), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}
