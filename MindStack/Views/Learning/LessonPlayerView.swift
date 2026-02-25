import SwiftUI

struct LessonPlayerView: View {
    let lesson: LearningLesson
    @State private var pageIndex: Int = 0
    @State private var showQuiz = false
    @State private var pages: [String] = []
    @State private var didAppear = false
    @State private var animateHeader = false

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                header

                TabView(selection: $pageIndex) {
                    ForEach(0..<max(1, pages.count), id: \.self) { idx in
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(lesson.title)
                                    .font(AppTypography.font(28, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.top, 10)

                                MarkdownView(markdown: pages.isEmpty ? lesson.contentMd : pages[idx])
                                    .padding(.top, 2)

                                Spacer(minLength: 160)
                            }
                            .padding(.horizontal, 18)
                            .padding(.bottom, 120)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .tag(idx)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.9), value: pageIndex)

                bottomBar
            }
        }
        .navigationTitle("Ders")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showQuiz) {
            QuizView(lessonId: lesson.id)
        }
        .onAppear {
            guard !didAppear else { return }
            didAppear = true
            pages = splitIntoPages(markdown: lesson.contentMd)
            Task { await updateProgress() }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                animateHeader = true
            }
        }
        .onChange(of: pageIndex) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            Task { await updateProgress() }
        }
    }

    private var header: some View {
        VStack(spacing: 10) {
            GeometryReader { g in
                let p = progressValue
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 8)
                    Capsule(style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: max(18, p * g.size.width), height: 8)
                        .glow(AppColors.primary, radius: 10)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 18)
            .padding(.top, 12)

            HStack {
                Text("Bölüm \(pageIndex + 1) / \(max(1, pages.count))")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
                HStack(spacing: 6) {
                    pageDots
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))

                Spacer().frame(width: 6)
                Text("≈ \(lesson.estMinutes) dk")
                    .font(AppTypography.font(12, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.25), Color.black.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<max(1, pages.count), id: \.self) { i in
                Capsule(style: .continuous)
                    .fill(i == pageIndex ? AppColors.primary : Color.white.opacity(0.18))
                    .frame(width: i == pageIndex ? 14 : 6, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: pageIndex)
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                        pageIndex = max(0, pageIndex - 1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(pageIndex == 0)
                .opacity(pageIndex == 0 ? 0.45 : 1)

                Button {
                    if isLastPage {
                        showQuiz = true
                    } else {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
                            pageIndex = min(max(0, pages.count - 1), pageIndex + 1)
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(isLastPage ? "Sorulara Geç" : "Devam")
                            .font(AppTypography.font(18, weight: .heavy))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 18)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .glow(AppColors.primary, radius: 18)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var isLastPage: Bool {
        guard !pages.isEmpty else { return true }
        return pageIndex >= pages.count - 1
    }

    private var progressValue: CGFloat {
        let count = max(1, pages.count)
        return CGFloat(pageIndex + 1) / CGFloat(count)
    }

    private func updateProgress() async {
        let count = max(1, pages.count)
        let pct = min(60, 10 + Int((Double(pageIndex + 1) / Double(count)) * 50))
        try? await LearningService.shared.upsertLessonProgress(lessonId: lesson.id, status: "in_progress", progressPct: pct)
    }

    private func splitIntoPages(markdown: String) -> [String] {
        let normalized = markdown
            .replacingOccurrences(of: "\\r\\n", with: "\n")
            .replacingOccurrences(of: "\\n", with: "\n")

        // Manuel sayfa bölücü: `---`
        let raw = normalized.components(separatedBy: "\n---\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let manual = raw.filter { !$0.isEmpty }
        if manual.count >= 2 { return manual }

        // Otomatik: başlıklara göre böl (en fazla 4 parça)
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        var chunks: [String] = []
        var current = ""
        for line in lines {
            let isHeading = line.trimmingCharacters(in: .whitespaces).hasPrefix("# ")
                || line.trimmingCharacters(in: .whitespaces).hasPrefix("## ")
            if isHeading, !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                chunks.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
                current = ""
            }
            current += line + "\n"
        }
        if !current.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chunks.append(current.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if chunks.count <= 1 { return [normalized] }

        // Çok fazla parça varsa birleştir
        if chunks.count > 4 {
            let merged = chunks.chunked(into: Int(ceil(Double(chunks.count) / 4.0))).map { $0.joined(separator: "\n\n") }
            return merged
        }

        return chunks
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
