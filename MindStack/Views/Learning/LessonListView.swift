import SwiftUI

struct LessonListView: View {
    let track: LearningTrack
    @StateObject private var learningVM = LearningViewModel()
    @State private var lessons: [LearningLesson] = []
    @State private var progressByLessonId: [UUID: LearningService.UserLessonProgressRow] = [:]
    @State private var isLoading = true

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(track.title)
                        .font(AppTypography.font(24, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, 6)

                    if let d = track.description {
                        Text(d)
                            .font(AppTypography.font(13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if isLoading {
                        ProgressView().tint(AppColors.primary).padding(.top, 24)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("DERS HARİTASI")
                                .font(AppTypography.font(11, weight: .bold))
                                .tracking(2.2)
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 10)

                            VStack(spacing: 8) {
                                ForEach(Array(lessons.enumerated()), id: \.element.id) { idx, lesson in
                                    let state = lessonState(index: idx)
                                    let isLast = idx == lessons.count - 1

                                    Group {
                                        if state.isLocked {
                                            PathLessonRow(
                                                lesson: lesson,
                                                state: state,
                                                isLast: isLast
                                            )
                                        } else {
                                            NavigationLink {
                                                LessonDetailView(lesson: lesson)
                                            } label: {
                                                PathLessonRow(
                                                    lesson: lesson,
                                                    state: state,
                                                    isLast: isLast
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .opacity(state.isLocked ? 0.55 : 1)
                                    .disabled(state.isLocked)
                                }
                            }
                        }
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Dersler")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            lessons = await learningVM.lessons(for: track)
            progressByLessonId = (try? await LearningService.shared.getLessonProgress(lessonIds: lessons.map(\.id))) ?? [:]
            isLoading = false
        }
    }

    private func lessonState(index: Int) -> LessonState {
        guard lessons.indices.contains(index) else { return .init(isLocked: false, status: nil, progressPct: 0) }
        let lesson = lessons[index]
        let row = progressByLessonId[lesson.id]

        let isCompleted = (row?.status == "completed") || ((row?.progressPct ?? 0) >= 100)
        let progressPct = row?.progressPct ?? 0

        // Lock: önceki ders bitmediyse
        if index > 0 {
            let prev = lessons[index - 1]
            let prevRow = progressByLessonId[prev.id]
            let prevCompleted = (prevRow?.status == "completed") || ((prevRow?.progressPct ?? 0) >= 100)
            if !prevCompleted && !isCompleted && progressPct == 0 {
                return .init(isLocked: true, status: row?.status, progressPct: progressPct)
            }
        }

        return .init(isLocked: false, status: isCompleted ? "completed" : row?.status, progressPct: progressPct)
    }
}

private struct PathLessonRow: View {
    let lesson: LearningLesson
    let state: LessonState
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(nodeFill)
                        .frame(width: 34, height: 34)
                        .overlay(Circle().stroke(nodeStroke, lineWidth: 2))
                        .glow(nodeGlow, radius: 14)

                    Image(systemName: nodeIcon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(nodeIconColor)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 3, height: 34)
                        .padding(.top, 6)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(lesson.title)
                        .font(AppTypography.font(15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Spacer()
                    badge
                }

                Text("≈ \(lesson.estMinutes) dk")
                    .font(AppTypography.font(12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)

                if !state.isLocked, state.progressPct > 0, state.progressPct < 100 {
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 8)
                            Capsule(style: .continuous)
                                .fill(AppColors.primary)
                                .frame(width: max(10, (CGFloat(state.progressPct) / 100) * g.size.width), height: 8)
                                .glow(AppColors.primary, radius: 10)
                        }
                    }
                    .frame(height: 8)
                    .padding(.top, 2)
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    private var badge: some View {
        Group {
            if state.status == "completed" || state.progressPct >= 100 {
                Text("BİTTİ")
                    .font(AppTypography.font(10, weight: .bold))
                    .tracking(2.0)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                    .overlay(Capsule(style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
            } else if state.isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.35))
            } else if state.progressPct > 0 {
                Text("%\(state.progressPct)")
                    .font(AppTypography.font(11, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.22))
            }
        }
    }

    private var nodeIcon: String {
        if state.status == "completed" || state.progressPct >= 100 { return "checkmark" }
        if state.isLocked { return "lock.fill" }
        if state.progressPct > 0 { return "play.fill" }
        return "bolt.fill"
    }

    private var nodeIconColor: Color {
        if state.isLocked { return Color.white.opacity(0.45) }
        if state.status == "completed" || state.progressPct >= 100 { return Color(hex: "#001216") }
        return Color(hex: "#001216")
    }

    private var nodeFill: Color {
        if state.isLocked { return Color.white.opacity(0.08) }
        if state.status == "completed" || state.progressPct >= 100 { return AppColors.primary }
        if state.progressPct > 0 { return AppColors.primary.opacity(0.85) }
        return AppColors.primary.opacity(0.65)
    }

    private var nodeStroke: Color {
        if state.isLocked { return Color.white.opacity(0.12) }
        return AppColors.primary.opacity(0.35)
    }

    private var nodeGlow: Color {
        if state.isLocked { return .clear }
        if state.status == "completed" || state.progressPct >= 100 { return AppColors.primary }
        return AppColors.primary.opacity(0.6)
    }
}

private struct LessonState: Hashable {
    let isLocked: Bool
    let status: String?
    let progressPct: Int
}
