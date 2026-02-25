import SwiftUI

struct TaskResultView: View {
    let result: TaskResult
    let onNext: () -> Void

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    Spacer(minLength: 26)

                    ZStack {
                        Circle()
                            .fill(AppColors.primary.opacity(0.12))
                            .frame(width: 220, height: 220)
                            .blur(radius: 50)

                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 110, height: 110)
                            .overlay(Circle().stroke(AppColors.primary.opacity(0.22), lineWidth: 1))

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .glow(AppColors.primary, radius: 20)
                    }
                    .padding(.top, 10)

                    VStack(spacing: 6) {
                        Text(result.title)
                            .font(AppTypography.font(32, weight: .heavy))
                            .foregroundColor(.white)
                        Text(result.subtitle)
                            .font(AppTypography.font(13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)

                    HStack(spacing: 12) {
                        StatCard(title: "Kazanılan XP", value: "+\(result.xpEarned)", accent: AppColors.primary)
                        StatCard(title: "Günlük Seri", value: "🔥 \(result.streak)", accent: .orange)
                    }
                    .padding(.horizontal, 18)

                    WhyCard(text: result.explanation, code: result.codeSnippet)
                        .padding(.horizontal, 18)

                    Spacer(minLength: 120)
                }
            }

            VStack {
                Spacer()
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Sonraki Görev")
                            .font(AppTypography.font(18, weight: .heavy))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .glow(AppColors.primary, radius: 18)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 16)
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        VStack(spacing: 10) {
            Text(title.uppercased(with: Locale(identifier: "tr_TR")))
                .font(AppTypography.font(11, weight: .bold))
                .tracking(2.0)
                .foregroundColor(AppColors.textTertiary)
            Text(value)
                .font(AppTypography.font(26, weight: .heavy))
                .foregroundColor(accent)
                .glow(accent, radius: 10)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct WhyCard: View {
    let text: String
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.primary)
                Text("Neden işe yarıyor?")
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06))

            VStack(alignment: .leading, spacing: 12) {
                Text(text)
                    .font(AppTypography.font(13, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(3)

                CodeBlock(code: code)
            }
            .padding(16)
        }
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct CodeBlock: View {
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Circle().fill(.yellow).frame(width: 8, height: 8)
                Circle().fill(.green).frame(width: 8, height: 8)
                Spacer()
            }
            Text(code)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.26), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.06), lineWidth: 1))
    }
}
