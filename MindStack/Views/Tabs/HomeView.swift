import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var featuredLessons: [LearningService.FeaturedLesson] = []
    @State private var isLoadingLessons = false
    @AppStorage("daily_goal_xp") private var dailyGoalXp: Int = 50

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    progressCard
                    dailyGoalCard
                    learnShortcut
                    featuredLearning
                    quote
                    Spacer(minLength: 110)
                }
                .padding(.top, 18)
                .padding(.horizontal, 18)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .task { await loadFeatured() }
            .refreshable { await loadFeatured(force: true) }

            bottomCTA
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle().fill(Color.white.opacity(0.14))
                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            }
            .frame(width: 42, height: 42)
            .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 2))

            VStack(alignment: .leading, spacing: 2) {
                Text("TEKRAR HOŞ GELDİN")
                    .font(AppTypography.font(10, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Text(appVM.user?.name ?? "Geliştirici")
                    .font(AppTypography.font(16, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.orange.opacity(0.95))
                Text("Gün \(appVM.user?.streak ?? 0)")
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.orange.opacity(0.95))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.16), in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.orange.opacity(0.18), lineWidth: 1)
            )
        }
        .padding(.top, 18)
    }

    private var progressCard: some View {
        let level = appVM.getCurrentLevel()
        return VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mevcut Seviye")
                        .font(AppTypography.font(12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                    Text(level.name)
                        .font(AppTypography.font(22, weight: .heavy))
                        .foregroundColor(AppColors.primary)
                        .glow(AppColors.primary, radius: 10)
                }
                Spacer()
                Text("\(appVM.user?.xp ?? 0) XP")
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.white.opacity(0.92))
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 10)
                    Capsule(style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: max(24, (CGFloat(level.progress) / 100) * g.size.width), height: 10)
                        .glow(AppColors.primary, radius: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Spacer()
                Text("Sonraki seviyeye \(level.xpToNext) XP")
                    .font(AppTypography.font(10, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var dailyGoalCard: some View {
        let todayXp = todayXP
        let goal = max(10, dailyGoalXp)
        let progress = min(1.0, Double(todayXp) / Double(goal))

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GÜNLÜK HEDEF")
                        .font(AppTypography.font(11, weight: .bold))
                        .tracking(2.2)
                        .foregroundColor(AppColors.textTertiary)
                    Text("\(todayXp) / \(goal) XP")
                        .font(AppTypography.font(18, weight: .heavy))
                        .foregroundColor(.white)
                }
                Spacer()
                if progress >= 1 {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                        Text("Tamam")
                    }
                    .font(AppTypography.font(12, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                }
            }

            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 10)
                    Capsule(style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: max(24, CGFloat(progress) * g.size.width), height: 10)
                        .glow(AppColors.primary, radius: 10)
                }
            }
            .frame(height: 10)

            HStack {
                Text("Hedefi ayarla")
                    .font(AppTypography.font(12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Stepper("", value: $dailyGoalXp, in: 10...300, step: 10)
                    .labelsHidden()
                    .tint(AppColors.primary)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var todayXP: Int {
        // AnalyticsService last 14 gün getiriyor; son gün = bugün (UTC tabanlı).
        // Boşsa 0.
        let today = Calendar(identifier: .gregorian).startOfDay(for: Date())
        if let exact = appVM.analytics.xpHistory.last(where: { Calendar(identifier: .gregorian).isDate($0.date, inSameDayAs: today) }) {
            return exact.xp
        }
        return appVM.analytics.xpHistory.last?.xp ?? 0
    }

    private var learnShortcut: some View {
        NavigationLink {
            LearnView()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.primary.opacity(0.14))
                        .frame(width: 54, height: 54)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.primary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Kategorilerden Öğren")
                        .font(AppTypography.font(16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Konu seç, dersi oku, sorularla pekiştir.")
                        .font(AppTypography.font(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.22))
            }
            .padding(16)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var featuredLearning: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Öne Çıkan Dersler")
                    .font(AppTypography.font(20, weight: .heavy))
                    .foregroundColor(.white)
                Spacer()
                if isLoadingLessons {
                    ProgressView().tint(AppColors.primary)
                }
            }

            if featuredLessons.isEmpty && !isLoadingLessons {
                Text("İçerik bulunamadı. `seed_content.sql` çalıştırdıysan yeniden dene.")
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(14)
                    .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.07), lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(featuredLessons) { item in
                        NavigationLink {
                            LessonDetailLoaderView(lessonId: item.id)
                        } label: {
                            FeaturedLessonRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.top, 6)
    }

    private var quote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(AppColors.primary)
                .font(.system(size: 18, weight: .bold))
            VStack(alignment: .leading, spacing: 4) {
                Text(#""Önce problemi çöz. Sonra kodu yaz.""#)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .italic()
                Text("— anonim")
                    .font(AppTypography.font(11, weight: .semibold))
                    .foregroundColor(AppColors.textTertiary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private var bottomCTA: some View {
        VStack {
            Spacer()
            NavigationLink {
                LearnView()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Öğrenmeye Devam Et")
                        .font(AppTypography.font(18, weight: .heavy))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .foregroundColor(Color(hex: "#001216"))
                .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .glow(AppColors.primary, radius: 18)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 14)
        }
    }

    private func loadFeatured(force: Bool = false) async {
        guard !isLoadingLessons else { return }
        if !featuredLessons.isEmpty && !force { return }
        isLoadingLessons = true
        defer { isLoadingLessons = false }

        do {
            featuredLessons = try await LearningService.shared.getFeaturedLessons(limit: 6)
        } catch {
            featuredLessons = []
        }
    }
}

private struct FeaturedLessonRow: View {
    let item: LearningService.FeaturedLesson

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: "book.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppTypography.font(15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Text(item.track.title)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("≈ \(item.estMinutes) dk")
                .font(AppTypography.font(12, weight: .bold))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct LessonDetailLoaderView: View {
    let lessonId: UUID
    @State private var lesson: LearningLesson?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if let lesson {
                LessonDetailView(lesson: lesson)
            } else {
                ZStack {
                    GradientBackground()
                    VStack(spacing: 14) {
                        if isLoading {
                            ProgressView().tint(AppColors.primary)
                        } else {
                            Text(errorMessage ?? "Ders yüklenemedi.")
                                .font(AppTypography.font(13, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .task { await load() }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            lesson = try await LearningService.shared.getLesson(id: lessonId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
