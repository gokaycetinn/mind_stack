import SwiftUI

struct LearnView: View {
    @StateObject private var learningVM = LearningViewModel()

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    if learningVM.isLoading {
                        ProgressView()
                            .tint(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 30)
                    } else if let error = learningVM.errorMessage {
                        Text(error)
                            .font(AppTypography.font(13, weight: .medium))
                            .foregroundColor(AppColors.error)
                            .padding(16)
                            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
                    } else {
                        categoryList
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Öğren")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await learningVM.loadCategories()
        }
        .refreshable {
            await learningVM.loadCategories(force: true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ne öğrenmek istersin?")
                .font(AppTypography.font(22, weight: .heavy))
                .foregroundColor(.white)
            Text("Kategorini seç, dersi oku, sorularla pekiştir.")
                .font(AppTypography.font(13, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(.top, 6)
    }

    private var categoryList: some View {
        VStack(spacing: 12) {
            ForEach(learningVM.categories) { category in
                NavigationLink {
                    TrackListView(category: category)
                } label: {
                    CategoryCard(category: category)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct CategoryCard: View {
    let category: LearningCategory

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppColors.primary.opacity(0.14))
                    .frame(width: 52, height: 52)
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(category.title)
                    .font(AppTypography.font(16, weight: .bold))
                    .foregroundColor(.white)
                if let d = category.description, !d.isEmpty {
                    Text(d)
                        .font(AppTypography.font(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
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
}

