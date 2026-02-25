import SwiftUI

struct ProblemSolvingTaskView: View {
    let onFinish: (TaskResult) -> Void

    @State private var selection: Option?

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("SYS‑DESIGN‑402 • RATE LIMITING")
                        .font(AppTypography.font(11, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                    Capsule(style: .continuous)
                        .fill(Color.orange.opacity(0.16))
                        .overlay(Capsule(style: .continuous).stroke(Color.orange.opacity(0.20), lineWidth: 1))
                        .overlay(
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill").font(.system(size: 12, weight: .bold))
                                Text("12 GÜNLÜK SERİ").font(AppTypography.font(11, weight: .bold))
                            }
                            .foregroundColor(Color.orange.opacity(0.95))
                            .padding(.horizontal, 12)
                        )
                        .frame(height: 34)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)

                Text("Sızdıran Kova (Leaky Bucket)")
                    .font(AppTypography.font(30, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)

                Text("Trafik yumuşatma için en uygun algoritmayı seç")
                    .font(AppTypography.font(13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 18)

                VStack(alignment: .leading, spacing: 12) {
                    Text("API rate limiter’ınız ani trafik artışlarında geçerli istekleri düşürüyor. Mevcut uygulama Fixed Window Counter kullanıyor.\n\nBurst’lere izin verirken aynı zamanda sabit bir hızla işleyip backend servisleri boğmayacak bir algoritmaya ihtiyacınız var.")
                        .font(AppTypography.font(13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(3)
                }
                .padding(16)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, 18)

                VStack(spacing: 12) {
                    OptionCard(title: "Token Bucket", subtitle: "Kova boyutuna kadar burst’e izin verir", isSelected: selection == .token) { selection = .token }
                    OptionCard(title: "Leaky Bucket", subtitle: "Trafiği sabit bir hıza yumuşatır", isSelected: selection == .leaky) { selection = .leaky }
                    OptionCard(title: "Fixed Window Counter", subtitle: "Basit ama sınır anlarında burst yapar", isSelected: selection == .fixed) { selection = .fixed }
                }
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    submit()
                } label: {
                    HStack {
                        Text("Testleri Çalıştır")
                            .font(AppTypography.font(18, weight: .heavy))
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(Color(hex: "#A78BFA"), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: Color(hex: "#A78BFA").opacity(0.35), radius: 18, x: 0, y: 8)
                }
                .disabled(selection == nil)
                .opacity(selection == nil ? 0.55 : 1)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
        }
    }

    private func submit() {
        let ok = selection == .leaky
        onFinish(
            TaskResult(
                title: ok ? "Harika düşünce!" : "Tekrar dene",
                subtitle: ok ? "Leaky Bucket burst’leri yumuşatır." : "Yumuşatma ile burst’e izin verme farkını düşün.",
                xpEarned: ok ? 45 : 12,
                streak: 12,
                explanation: "Leaky Bucket, burst şeklinde gelen trafiği sabit bir çıkış hızına dönüştürerek aşağıdaki servisleri korur. Token Bucket burst’e izin vermede iyidir, fakat soru sabit yumuşatma istiyor.",
                codeSnippet: """
                # Leaky Bucket: queue requests, drain at constant rate
                enqueue(request)
                while tokensAvailable:
                  process(next)
                """
            )
        )
    }

    private enum Option { case token, leaky, fixed }
}

private struct OptionCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.font(15, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(AppTypography.font(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                Circle()
                    .stroke(Color.white.opacity(0.22), lineWidth: 2)
                    .background(Circle().fill(isSelected ? AppColors.primary : Color.clear))
                    .frame(width: 20, height: 20)
            }
            .padding(16)
            .background(Color.white.opacity(isSelected ? 0.09 : 0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? AppColors.primary.opacity(0.35) : Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
