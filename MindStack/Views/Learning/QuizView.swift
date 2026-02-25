import SwiftUI
import UIKit

struct QuizView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appVM: AppViewModel

    let lessonId: UUID

    @State private var questions: [LearningQuestion] = []
    @State private var optionsByQuestion: [UUID: [LearningOption]] = [:]
    @State private var index = 0

    @State private var selectedOptionIds: Set<UUID> = []
    @State private var isSubmitting = false
    @State private var feedback: Feedback?
    @State private var showExplanationCard = false
    @State private var lastWasCorrect: Bool = false
    @State private var lastExplanation: String?
    @State private var lastCorrectOptionIds: Set<UUID> = []
    @State private var lastXpEarned: Int = 0
    @State private var animateXP = false
    @State private var questionStartedAt: Date = .now
    @State private var celebration: Celebration?
    @State private var sessionXp: Int = 0
    @State private var sessionCorrect: Int = 0
    @State private var sessionWrong: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                if questions.isEmpty {
                    ProgressView()
                        .tint(AppColors.primary)
                        .task { await load() }
                } else {
                    content
                }

                if let feedback {
                    toast(text: feedback.text, success: feedback.success)
                }

                if showExplanationCard {
                    explanationOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if let celebration {
                    CelebrationOverlay(
                        title: celebration.title,
                        subtitle: celebration.subtitle,
                        accent: celebration.accent,
                        systemImage: celebration.systemImage,
                        xp: celebration.xp,
                        primaryButtonTitle: celebration.buttonTitle
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) { self.celebration = nil }
                        if celebration.action == .dismissQuiz {
                            dismiss()
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var content: some View {
        let q = questions[index]
        let opts = optionsByQuestion[q.id] ?? []

        return VStack(spacing: 0) {
            progressHeader

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Soru \(index + 1) / \(questions.count)")
                        .font(AppTypography.font(11, weight: .bold))
                        .tracking(2.2)
                        .foregroundColor(AppColors.textTertiary)
                    Spacer()
                    Text("+\(q.xpReward) XP")
                        .font(AppTypography.font(12, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                }

                Text(q.prompt)
                    .font(AppTypography.font(20, weight: .heavy))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                if q.type == .multiChoice {
                    Text("Birden fazla seçenek doğru olabilir.")
                        .font(AppTypography.font(12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 2)
                }

                if opts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bu soru için seçenekler yüklenemedi.")
                            .font(AppTypography.font(13, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                        Button {
                            Task { await load() }
                        } label: {
                            Text("Tekrar Dene")
                                .font(AppTypography.font(13, weight: .bold))
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.top, 8)
                } else {
                    VStack(spacing: 10) {
                        ForEach(opts) { opt in
                            OptionRow(
                                text: opt.text,
                                isSelected: selectedOptionIds.contains(opt.id),
                                selectionStyle: q.type == .multiChoice ? .multiple : .single,
                                isCorrect: lastCorrectOptionIds.contains(opt.id),
                                isWrongSelected: showExplanationCard && selectedOptionIds.contains(opt.id) && !lastCorrectOptionIds.contains(opt.id),
                                showResult: showExplanationCard
                            ) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                toggleSelection(for: q, optionId: opt.id)
                            }
                        }
                    }
                    .padding(.top, 6)
                }

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Button {
                    Task { await submit() }
                } label: {
                    HStack {
                        if isSubmitting {
                            ProgressView().tint(Color(hex: "#001216"))
                        } else {
                            Text(index == questions.count - 1 ? "Bitir" : "Cevabı Gönder")
                                .font(AppTypography.font(18, weight: .heavy))
                        }
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
                .disabled(isSubmitting || selectedOptionIds.isEmpty || showExplanationCard)
                .opacity(selectedOptionIds.isEmpty ? 0.55 : 1)
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
    }

    private var progressHeader: some View {
        VStack(spacing: 10) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 8)

                    Capsule(style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: max(18, (CGFloat(index + 1) / CGFloat(max(1, questions.count))) * g.size.width), height: 8)
                        .glow(AppColors.primary, radius: 10)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, 18)
            .padding(.top, 12)
        }
        .background(Color.black.opacity(0.10))
    }

    private func load() async {
        do {
            let items = try await LearningService.shared.getQuestionsWithOptions(lessonId: lessonId)
            questions = items.map {
                LearningQuestion(
                    id: $0.id,
                    lessonId: $0.lessonId,
                    type: $0.type,
                    prompt: $0.prompt,
                    explanation: $0.explanation,
                    difficulty: $0.difficulty,
                    xpReward: $0.xpReward,
                    sort: $0.sort,
                    createdAt: $0.createdAt
                )
            }
            optionsByQuestion = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0.options) })

            // Güvenlik: bazı ortamlarda nested select boş dönebilir; fallback dene.
            if optionsByQuestion.values.allSatisfy({ $0.isEmpty }), !questions.isEmpty {
                var dict: [UUID: [LearningOption]] = [:]
                for q in questions {
                    dict[q.id] = try await LearningService.shared.getOptions(questionId: q.id)
                }
                optionsByQuestion = dict
            }
            questionStartedAt = .now
        } catch {
            feedback = .init(text: error.localizedDescription, success: false)
        }
    }

    private func submit() async {
        guard !selectedOptionIds.isEmpty else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let q = questions[index]
        let opts = optionsByQuestion[q.id] ?? []
        let correctIds = Set(opts.filter { $0.isCorrect }.map(\.id))
        let chosenIds = selectedOptionIds
        let isCorrect: Bool = {
            switch q.type {
            case .singleChoice, .trueFalse:
                return chosenIds.count == 1 && chosenIds == correctIds
            case .multiChoice:
                return !correctIds.isEmpty && chosenIds == correctIds
            }
        }()
        let durationMs = Int(Date().timeIntervalSince(questionStartedAt) * 1000)

        do {
            let oldStreak = appVM.user?.streak ?? 0
            let oldLevelId = appVM.getCurrentLevel().levelId

            let result = try await LearningService.shared.recordAttempt(
                questionId: q.id,
                isCorrect: isCorrect,
                chosenOptionIds: Array(chosenIds),
                durationMs: max(0, durationMs)
            )

            if var u = appVM.user {
                u.totalXp = result.totalXp
                u.xp = result.totalXp
                u.streak = result.currentStreak
                u.lastActivityDate = Date()
                appVM.user = u
            }

            lastWasCorrect = isCorrect
            lastExplanation = q.explanation
            lastCorrectOptionIds = correctIds
            lastXpEarned = isCorrect ? q.xpReward : 0
            if isCorrect {
                sessionXp += q.xpReward
                sessionCorrect += 1
            } else {
                sessionWrong += 1
            }

            if isCorrect {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }

            // Duolingo benzeri kutlamalar
            let newLevelId = appVM.getCurrentLevel().levelId
            if result.currentStreak > oldStreak {
                celebration = .init(
                    title: "Seri başladı!",
                    subtitle: "Harika. Bugünkü öğrenme serin: \(result.currentStreak) gün.",
                    accent: .orange.opacity(0.95),
                    systemImage: "flame.fill",
                    xp: nil,
                    buttonTitle: "Devam Et",
                    action: .close
                )
            } else if newLevelId > oldLevelId {
                let level = appVM.getCurrentLevel()
                celebration = .init(
                    title: "Seviye Atladın!",
                    subtitle: "Yeni seviye: \(level.name). Böyle devam.",
                    accent: AppColors.purple,
                    systemImage: "sparkles",
                    xp: lastXpEarned,
                    buttonTitle: "Harika",
                    action: .close
                )
            }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                showExplanationCard = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    feedback = nil
                }
            }

        } catch {
            feedback = .init(text: error.localizedDescription, success: false)
        }
    }

    private func toggleSelection(for question: LearningQuestion, optionId: UUID) {
        if question.type == .multiChoice {
            if selectedOptionIds.contains(optionId) {
                selectedOptionIds.remove(optionId)
            } else {
                selectedOptionIds.insert(optionId)
            }
            return
        }

        // single_choice + true_false
        selectedOptionIds = [optionId]
    }

    private var explanationOverlay: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: lastWasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(lastWasCorrect ? AppColors.primary : AppColors.error)
                        .glow(lastWasCorrect ? AppColors.primary : AppColors.error, radius: 12)

                    Text(lastWasCorrect ? "Doğru!" : "Yanlış")
                        .font(AppTypography.font(18, weight: .heavy))
                        .foregroundColor(.white)

                    Spacer()

                    if animateXP {
                        Text("+\(lastXpEarned) XP")
                            .font(AppTypography.font(14, weight: .bold))
                            .foregroundColor(AppColors.primary)
                            .transition(.opacity.combined(with: .scale))
                    }
                }

                if let exp = lastExplanation, !exp.isEmpty {
                    Text(exp)
                        .font(AppTypography.font(13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineSpacing(3)
                } else {
                    Text(lastWasCorrect ? "Harika! Devam edelim." : "Soruyu tekrar düşün ve devam et.")
                        .font(AppTypography.font(13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                        showExplanationCard = false
                    }

                    if index < questions.count - 1 {
                        index += 1
                        selectedOptionIds = []
                        lastCorrectOptionIds = []
                        lastXpEarned = 0
                        questionStartedAt = .now
                    } else {
                        Task { try? await LearningService.shared.upsertLessonProgress(lessonId: lessonId, status: "completed", progressPct: 100) }
                        celebration = .init(
                            title: "Ders Tamamlandı!",
                            subtitle: "Doğru: \(sessionCorrect) • Yanlış: \(sessionWrong)",
                            accent: AppColors.primary,
                            systemImage: "checkmark.circle.fill",
                            xp: sessionXp,
                            buttonTitle: "Harika",
                            action: .dismissQuiz
                        )
                    }
                } label: {
                    HStack {
                        Text(index == questions.count - 1 ? "Bitir" : "Devam")
                            .font(AppTypography.font(16, weight: .heavy))
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .glow(AppColors.primary, radius: 14)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(Color.black.opacity(0.40), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 16)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
                    animateXP = lastWasCorrect
                }
            }
            .onDisappear { animateXP = false }
        }
        .ignoresSafeArea()
    }

    private func toast(text: String, success: Bool) -> some View {
        VStack {
            Spacer()
            Text(text)
                .font(AppTypography.font(12, weight: .bold))
                .foregroundColor(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke((success ? AppColors.primary : AppColors.error).opacity(0.22), lineWidth: 1)
                )
                .padding(.bottom, 86)
        }
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    private struct Feedback: Equatable {
        let text: String
        let success: Bool
    }

    private struct Celebration: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let subtitle: String
        let accent: Color
        let systemImage: String
        let xp: Int?
        let buttonTitle: String
        let action: Action

        enum Action: Equatable {
            case close
            case dismissQuiz
        }
    }
}

private struct OptionRow: View {
    let text: String
    let isSelected: Bool
    let selectionStyle: SelectionStyle
    let isCorrect: Bool
    let isWrongSelected: Bool
    let showResult: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(text)
                        .font(AppTypography.font(14, weight: .semibold))
                        .foregroundColor(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                indicator
            }
            .padding(16)
            .background(Color.white.opacity(isSelected ? 0.09 : 0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(overlayColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(showResult)
    }

    private var indicator: some View {
        Group {
            switch selectionStyle {
            case .single:
                Circle()
                    .stroke(borderColor, lineWidth: 2)
                    .background(Circle().fill(isSelected ? fillColor : Color.clear))
                    .frame(width: 20, height: 20)
            case .multiple:
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(borderColor, lineWidth: 2)
                    .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(isSelected ? fillColor : Color.clear))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "#001216"))
                            .opacity(isSelected ? 1 : 0)
                    )
            }
        }
    }

    private var borderColor: Color {
        if showResult, isCorrect { return AppColors.primary.opacity(0.9) }
        if showResult, isWrongSelected { return AppColors.error.opacity(0.9) }
        return Color.white.opacity(0.22)
    }

    private var fillColor: Color {
        if showResult, isCorrect { return AppColors.primary }
        if showResult, isWrongSelected { return AppColors.error }
        return AppColors.primary
    }

    private var overlayColor: Color {
        if showResult, isCorrect { return AppColors.primary.opacity(0.35) }
        if showResult, isWrongSelected { return AppColors.error.opacity(0.35) }
        return isSelected ? AppColors.primary.opacity(0.35) : Color.white.opacity(0.08)
    }

    enum SelectionStyle {
        case single
        case multiple
    }
}
