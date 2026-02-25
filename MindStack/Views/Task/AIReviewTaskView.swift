import SwiftUI

struct AIReviewTaskView: View {
    let onFinish: (TaskResult) -> Void

    @State private var selection: Answer?

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(alignment: .leading, spacing: 14) {
                topBar

                codeCard
                    .padding(.horizontal, 18)

                Text("Asıl sorun nedir?")
                    .font(AppTypography.font(22, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.horizontal, 18)
                    .padding(.top, 2)

                Text("Recursive fonksiyon mantığını analiz et. Parametrenin çağrılar arasında nasıl değiştiğine dikkat et.")
                    .font(AppTypography.font(13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 18)

                VStack(spacing: 12) {
                    AnswerCard(
                        title: "Performans Darboğazı",
                        subtitle: "Verimsiz bellek kullanımı",
                        isSelected: selection == .performance
                    ) { selection = .performance }
                    AnswerCard(
                        title: "Sonsuz Özyineleme",
                        subtitle: "Base case’e ilerleme yok",
                        isSelected: selection == .infiniteRecursion
                    ) { selection = .infiniteRecursion }
                    AnswerCard(
                        title: "Söz Dizimi Hatası",
                        subtitle: "Geçersiz Python söz dizimi",
                        isSelected: selection == .syntax
                    ) { selection = .syntax }
                }
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    submit()
                } label: {
                    Text("İncelemeyi Gönder")
                        .font(AppTypography.font(18, weight: .heavy))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(Color(hex: "#001216"))
                        .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .glow(AppColors.primary, radius: 18)
                }
                .disabled(selection == nil)
                .opacity(selection == nil ? 0.55 : 1)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("YZ İnceleme Görevi")
                .font(AppTypography.font(12, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
            Text("PRO")
                .font(AppTypography.font(10, weight: .heavy))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundColor(Color(hex: "#001216"))
                .background(AppColors.primary, in: Capsule(style: .continuous))
            Spacer()
            Text("3/5")
                .font(AppTypography.font(11, weight: .bold))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
    }

    private var codeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle().fill(Color.red).frame(width: 8, height: 8)
                Circle().fill(Color.yellow).frame(width: 8, height: 8)
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Spacer()
                Text("recursion_bug.py")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.35))
            }

            Text(
                """
                def calculate_sum(n):
                    if n == 0:
                        return 0
                    return n + calculate_sum(n)
                """
            )
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundColor(Color.white.opacity(0.92))
            .padding(12)
            .background(Color.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func submit() {
        let ok = selection == .infiniteRecursion
        onFinish(
            TaskResult(
                title: ok ? "Harika düşünce!" : "Tam değil",
                subtitle: ok ? "Özyineleme hatasını yakaladın." : "`n` değerinin çağrılar arasında nasıl değiştiğine bak.",
                xpEarned: ok ? 45 : 12,
                streak: 12,
                explanation: "Recursive çağrı `n` değerini azaltmadan tekrar `calculate_sum(n)` çağırıyor, bu yüzden base case’e hiç ulaşmıyor. `calculate_sum(n - 1)` çağırmalı.",
                codeSnippet: """
                def calculate_sum(n):
                  if n == 0: return 0
                  return n + calculate_sum(n - 1)
                """
            )
        )
    }

    private enum Answer { case performance, infiniteRecursion, syntax }
}

private struct AnswerCard: View {
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
