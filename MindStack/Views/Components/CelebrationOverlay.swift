import SwiftUI

struct CelebrationOverlay: View {
    let title: String
    let subtitle: String
    let accent: Color
    let systemImage: String
    let xp: Int?
    let primaryButtonTitle: String
    let onPrimary: () -> Void

    @State private var animate = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onPrimary() }

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(accent.opacity(0.16))
                        .frame(width: 92, height: 92)
                        .overlay(Circle().stroke(accent.opacity(0.22), lineWidth: 2))
                        .scaleEffect(animate ? 1.0 : 0.92)

                    Image(systemName: systemImage)
                        .font(.system(size: 38, weight: .heavy))
                        .foregroundColor(accent)
                        .glow(accent, radius: 18)
                }

                Text(title)
                    .font(AppTypography.font(28, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(AppTypography.font(13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                if let xp, xp > 0 {
                    Text("+\(xp) XP")
                        .font(AppTypography.font(16, weight: .heavy))
                        .foregroundColor(accent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(accent.opacity(0.12), in: Capsule(style: .continuous))
                        .transition(.opacity.combined(with: .scale))
                }

                Button {
                    onPrimary()
                } label: {
                    HStack {
                        Text(primaryButtonTitle)
                            .font(AppTypography.font(16, weight: .heavy))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(accent, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .glow(accent, radius: 14)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
            .padding(18)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .padding(.horizontal, 18)
            .overlay(ConfettiLayer(animate: animate, tint: accent).ignoresSafeArea())
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

private struct ConfettiLayer: View {
    let animate: Bool
    let tint: Color

    private let pieces = Array(0..<26)

    var body: some View {
        GeometryReader { g in
            ForEach(pieces, id: \.self) { i in
                let x = CGFloat((i * 37) % 300) / 300.0
                let delay = Double(i) * 0.03
                let size = CGFloat(8 + (i % 6))

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill((i % 3 == 0 ? tint : (i % 3 == 1 ? Color.white.opacity(0.85) : AppColors.purple.opacity(0.9))).opacity(0.9))
                    .frame(width: size, height: size * 1.35)
                    .rotationEffect(.degrees(animate ? Double(i * 28) : 0))
                    .position(x: g.size.width * x, y: animate ? g.size.height + 40 : -40)
                    .animation(.easeIn(duration: 1.1).delay(delay), value: animate)
            }
        }
        .allowsHitTesting(false)
    }
}

