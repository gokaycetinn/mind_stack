import SwiftUI

/// Premium Markdown renderer:
/// - DB'de `\\n` / `\\\"` kaçışlarını normalize eder.
/// - Başlıklar, listeler, ayırıcılar, callout'lar ve code block'ları özel UI ile gösterir.
struct MarkdownView: View {
    let markdown: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                switch block {
                case .h1(let t):
                    Text(t)
                        .font(AppTypography.font(22, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, 2)

                case .h2(let t):
                    Text(t)
                        .font(AppTypography.font(18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 4)

                case .paragraph(let md):
                    Paragraph(md: md)

                case .bullets(let items):
                    BulletList(items: items)

                case .divider:
                    Divider()
                        .overlay(Color.white.opacity(0.10))
                        .padding(.vertical, 2)

                case .callout(let title, let message):
                    CalloutCard(title: title, message: message)

                case .code(let code, let language):
                    CodeBlockView(code: code, languageLabel: language)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum Block: Equatable {
        case h1(String)
        case h2(String)
        case paragraph(String)
        case bullets([String])
        case divider
        case callout(title: String, body: String)
        case code(String, language: String?)
    }

    private var blocks: [Block] {
        let normalized = markdown
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\n", with: "\n")
            .replacingOccurrences(of: "\\t", with: "\t")
            // Seed/SQL kaynaklı kaçışlar
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\\\", with: "\\")

        var result: [Block] = []

        func flushParagraph(_ text: inout String) {
            let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !t.isEmpty else { text = ""; return }
            result.append(.paragraph(t))
            text = ""
        }

        func flushBullets(_ bullets: inout [String]) {
            let items = bullets.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            guard !items.isEmpty else { bullets = []; return }
            result.append(.bullets(items))
            bullets = []
        }

        var paragraph = ""
        var bullets: [String] = []
        var code = ""
        var inCode = false
        var codeLang: String?

        for rawLine in normalized.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine)
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("```") {
                if inCode {
                    result.append(.code(code, language: codeLang))
                    code = ""
                    codeLang = nil
                } else {
                    flushBullets(&bullets)
                    flushParagraph(&paragraph)
                    let lang = trimmed.replacingOccurrences(of: "```", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    codeLang = lang.isEmpty ? nil : lang
                }
                inCode.toggle()
                continue
            }

            if inCode {
                code += line + "\n"
                continue
            }

            if trimmed == "---" {
                flushBullets(&bullets)
                flushParagraph(&paragraph)
                result.append(.divider)
                continue
            }

            if trimmed.hasPrefix("# ") {
                flushBullets(&bullets)
                flushParagraph(&paragraph)
                result.append(.h1(String(trimmed.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)))
                continue
            }

            if trimmed.hasPrefix("## ") {
                flushBullets(&bullets)
                flushParagraph(&paragraph)
                result.append(.h2(String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespacesAndNewlines)))
                continue
            }

            if trimmed.lowercased().hasPrefix("ipucu:") || trimmed.lowercased().hasPrefix("kural:") {
                flushBullets(&bullets)
                flushParagraph(&paragraph)
                let parts = trimmed.split(separator: ":", maxSplits: 1).map(String.init)
                let title = parts.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "İpucu"
                let body = (parts.count > 1 ? parts[1] : "").trimmingCharacters(in: .whitespacesAndNewlines)
                result.append(.callout(title: title, body: body))
                continue
            }

            if trimmed.hasPrefix("- ") {
                flushParagraph(&paragraph)
                bullets.append(String(trimmed.dropFirst(2)))
                continue
            }

            if trimmed.isEmpty {
                flushBullets(&bullets)
                flushParagraph(&paragraph)
                continue
            }

            paragraph += line + "\n"
        }

        if inCode {
            // Unclosed fence: show as paragraph
            paragraph += "```" + "\n" + code
        }

        flushBullets(&bullets)
        flushParagraph(&paragraph)

        return result.isEmpty ? [.paragraph(normalized)] : result
    }
}

private struct Paragraph: View {
    let md: String

    var body: some View {
        if let attr = try? AttributedString(
            markdown: md,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            Text(attr)
                .font(AppTypography.font(14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        } else {
            Text(md)
                .font(AppTypography.font(14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(4)
        }
    }
}

private struct BulletList: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(AppColors.primary.opacity(0.85))
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                    Paragraph(md: item)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.07), lineWidth: 1))
    }
}

private struct CalloutCard: View {
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(AppColors.primary.opacity(0.16))
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .glow(AppColors.primary, radius: 10)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text(title.uppercased())
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Text(message)
                    .font(AppTypography.font(13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(14)
        .background(AppColors.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
    }
}
