import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.94
    @State private var opacity: Double = 0
    @State private var showResetToast = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.black.opacity(0.22))
                        .frame(width: 120, height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(AppColors.primary.opacity(0.18), lineWidth: 1)
                        )
                        .glow(AppColors.primary, radius: 22)

                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.clear)
                        .overlay(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .mask(Image(systemName: "chevron.left.forwardslash.chevron.right").font(.system(size: 46, weight: .bold)))
                        )
                        .glow(AppColors.primary, radius: 16)
                }

                Text("MindStack")
                    .font(AppTypography.font(44, weight: .heavy))
                    .foregroundColor(.clear)
                    .overlay(
                        LinearGradient(
                            colors: [Color.white, AppColors.primary.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .mask(Text("MindStack").font(AppTypography.font(44, weight: .heavy)))
                    )

                Text("BİR GELİŞTİRİCİ GİBİ DÜŞÜN")
                    .font(AppTypography.font(12, weight: .semibold, design: .rounded))
                    .tracking(3.4)
                    .foregroundColor(AppColors.primary.opacity(0.55))
            }
            .scaleEffect(scale)
            .opacity(opacity)

            VStack(spacing: 10) {
                Spacer()

                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 99, style: .continuous)
                        .fill(AppColors.primary.opacity(0.15))
                        .frame(width: 56, height: 4)

                    RoundedRectangle(cornerRadius: 99, style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: 18, height: 4)
                        .offset(x: shimmerOffset)
                        .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: shimmerOffset)
                }

                Text("v2.4.0")
                    .font(AppTypography.font(10, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.textTertiary.opacity(0.6))
                    .onLongPressGesture(minimumDuration: 0.8) {
                        UserDefaults.standard.set(false, forKey: "isOnboarded")
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            showResetToast = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                                showResetToast = false
                            }
                        }
                    }
            }
            .padding(.bottom, 40)

            if showResetToast {
                VStack {
                    Spacer()
                    Text("Sıfırlandı: onboarding tekrar gösterilecek")
                        .font(AppTypography.font(12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
                        .overlay(Capsule(style: .continuous).stroke(AppColors.primary.opacity(0.22), lineWidth: 1))
                        .padding(.bottom, 90)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.72)) {
                scale = 1
                opacity = 1
            }
            shimmerOffset = 44
        }
    }

    @State private var shimmerOffset: CGFloat = -18
}
