import SwiftUI
import UIKit

struct CodeBlockView: View {
    let code: String
    let languageLabel: String?

    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                if let languageLabel, !languageLabel.isEmpty {
                    Text(languageLabel.uppercased())
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                } else {
                    Text("KOD")
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = code.trimmingCharacters(in: .whitespacesAndNewlines)
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCopied = false
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? "Kopyalandı" : "Kopyala")
                            .font(AppTypography.font(12, weight: .bold))
                    }
                    .foregroundColor(showCopied ? AppColors.primary : AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                Text(code.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.92))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
        }
        .padding(14)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }
}

