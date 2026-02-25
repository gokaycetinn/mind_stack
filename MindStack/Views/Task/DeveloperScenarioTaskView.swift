import SwiftUI

struct DeveloperScenarioTaskView: View {
    let onFinish: (TaskResult) -> Void

    @State private var selection: Choice?

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(alignment: .leading, spacing: 14) {
                topBar

                VStack(alignment: .leading, spacing: 10) {
                    Text("Main Branch’te Felaket")
                        .font(AppTypography.font(30, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Stratejini seç\nEn güvenli ve uygun Git komutunu belirle.")
                        .font(AppTypography.font(13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(3)
                }
                .padding(.horizontal, 18)

                VStack(spacing: 12) {
                    ScenarioChoiceCard(
                        title: "git revert HEAD",
                        subtitle: "Değişiklikleri geri alan yeni bir commit oluşturur. Geçmişi korur.",
                        icon: "arrow.uturn.backward",
                        accent: Color(hex: "#60A5FA"),
                        isSelected: selection == .revert
                    ) { selection = .revert }

                    ScenarioChoiceCard(
                        title: "git reset --hard",
                        subtitle: "Commit’i lokalden siler. Push etmediysen bile yıkıcı olabilir.",
                        icon: "flame.fill",
                        accent: Color(hex: "#F59E0B"),
                        isSelected: selection == .resetHard
                    ) { selection = .resetHard }

                    ScenarioChoiceCard(
                        title: "git push --force",
                        subtitle: "Remote geçmişi ezer. Paylaşılan branch’lerde çok tehlikelidir.",
                        icon: "exclamationmark.triangle.fill",
                        accent: Color(hex: "#F87171"),
                        isSelected: selection == .forcePush
                    ) { selection = .forcePush }
                }
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    submit()
                } label: {
                    HStack {
                        Text("Kararı Onayla")
                            .font(AppTypography.font(18, weight: .heavy))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)
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
            Capsule(style: .continuous)
                .fill(Color.orange.opacity(0.16))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.orange.opacity(0.20), lineWidth: 1)
                )
                .frame(height: 34)
                .overlay(
                    Text("GERÇEK GELİŞTİRİCİ SENARYOSU")
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(2.2)
                        .foregroundColor(Color.orange.opacity(0.95))
                        .padding(.horizontal, 10)
                )
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
    }

    private func submit() {
        let ok = selection == .revert
        onFinish(
            TaskResult(
                title: ok ? "Harika düşünce!" : "Riskli seçim",
                subtitle: ok ? "En güvenli stratejiyi seçtin." : "Bu seçenek paylaşılan branch’lerde yıkıcı olabilir.",
                xpEarned: ok ? 45 : 10,
                streak: 12,
                explanation: "Paylaşılan branch’lerde `git revert` geçmişi korur ve ekipler için güvenlidir. `reset --hard` ve `push --force` geçmişi yeniden yazar ve başkaları için çakışmalara yol açabilir.",
                codeSnippet: """
                # safest on shared branches
                git revert HEAD
                """
            )
        )
    }

    private enum Choice { case revert, resetHard, forcePush }
}

private struct ScenarioChoiceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(accent.opacity(0.14))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(accent)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(AppTypography.font(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Circle()
                    .stroke(Color.white.opacity(0.20), lineWidth: 2)
                    .background(Circle().fill(isSelected ? AppColors.primary : Color.clear))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#001216"))
                            .opacity(isSelected ? 1 : 0)
                    )
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
