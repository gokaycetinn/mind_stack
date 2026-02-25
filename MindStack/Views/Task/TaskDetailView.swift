import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject private var appVM: AppViewModel
    let task: MindTask

    @State private var showPlay = false

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Seans")
                            .font(AppTypography.font(18, weight: .heavy))
                            .foregroundColor(.white)

                        HStack {
                            Label("\(task.durationMinutes) dk", systemImage: "clock.fill")
                            Spacer()
                            Label("+\(task.xpReward) XP", systemImage: "bolt.fill")
                        }
                        .font(AppTypography.font(13, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(14)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }

                    VStack(spacing: 10) {
                        Button {
                            showPlay = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                Text(task.isLocked ? "Kilitli" : "Başla")
                                    .font(AppTypography.font(18, weight: .heavy))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 18)
                            .foregroundColor(Color(hex: "#001216"))
                            .background(task.isLocked ? Color.white.opacity(0.18) : AppColors.primary, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .glow(task.isLocked ? .clear : AppColors.primary, radius: 18)
                        }
                        .buttonStyle(.plain)
                        .disabled(task.isLocked)

                        if task.isLocked {
                            Button {
                                showPlay = true
                            } label: {
                                HStack {
                                    Text("Önizleme")
                                        .font(AppTypography.font(14, weight: .bold))
                                    Spacer()
                                    Image(systemName: "eye.fill")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .foregroundColor(AppColors.primary)
                                .background(AppColors.primary.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 6)

                    Spacer(minLength: 60)
                }
                .padding(.top, 18)
                .padding(.horizontal, 18)
            }
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPlay) {
            TaskPlayView(task: task)
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(hex: task.colorHex).opacity(0.20))
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(hex: task.colorHex).opacity(0.25), lineWidth: 1)
                    )
                Image(systemName: task.iconSystemName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: task.colorHex))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(AppTypography.font(24, weight: .heavy))
                    .foregroundColor(.white)
                Text(task.subtitle)
                    .font(AppTypography.font(14, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)

                if task.isLocked {
                    Text("KİLİTLİ")
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(.orange.opacity(0.95))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.16), in: Capsule(style: .continuous))
                        .overlay(Capsule(style: .continuous).stroke(Color.orange.opacity(0.18), lineWidth: 1))
                        .padding(.top, 6)
                }
            }
            Spacer()
        }
        .padding(18)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct TaskPlayView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appVM: AppViewModel
    let task: MindTask

    @State private var result: TaskResult?

    var body: some View {
        NavigationStack {
            ZStack {
                switch task.category {
                case .algorithmicThinking:
                    AlgorithmicThinkingTaskView(onFinish: finish)
                case .developerScenario:
                    DeveloperScenarioTaskView(onFinish: finish)
                case .aiReview:
                    AIReviewTaskView(onFinish: finish)
                case .problemSolving:
                    ProblemSolvingTaskView(onFinish: finish)
                }

                if let result {
                    TaskResultView(result: result) {
                        appVM.markTaskCompleted(task.id, xpGained: result.xpEarned)
                        dismiss()
                    }
                    .transition(.opacity)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if result == nil {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.5, dampingFraction: 0.9), value: result != nil)
    }

    private func finish(_ result: TaskResult) {
        self.result = result
    }
}

struct TaskResult: Equatable {
    let title: String
    let subtitle: String
    let xpEarned: Int
    let streak: Int
    let explanation: String
    let codeSnippet: String
}
