import SwiftUI

struct TrackListView: View {
    let category: LearningCategory
    @StateObject private var learningVM = LearningViewModel()
    @State private var tracks: [LearningTrack] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(category.title)
                        .font(AppTypography.font(24, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, 6)

                    if let d = category.description {
                        Text(d)
                            .font(AppTypography.font(13, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }

                    if isLoading {
                        ProgressView().tint(AppColors.primary).padding(.top, 24)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(tracks) { track in
                                NavigationLink {
                                    LessonListView(track: track)
                                } label: {
                                    TrackCard(track: track)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 10)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Konular")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            tracks = await learningVM.tracks(for: category)
            isLoading = false
        }
    }
}

private struct TrackCard: View {
    let track: LearningTrack

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(track.title)
                    .font(AppTypography.font(16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if let level = track.level, !level.isEmpty {
                    Text(level.uppercased(with: Locale(identifier: "tr_TR")))
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(2.0)
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                        .overlay(Capsule(style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))
                }
            }

            if let d = track.description, !d.isEmpty {
                Text(d)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(3)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

