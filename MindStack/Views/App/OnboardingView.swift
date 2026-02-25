import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var page: Int = 0

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.primary.opacity(0.9))
                        .padding(10)
                        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(AppColors.primary.opacity(0.12), lineWidth: 1)
                        )

                    Spacer()

                    Button("Geç") { appVM.setOnboarded(true) }
                        .font(AppTypography.font(13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                TabView(selection: $page) {
                    OnboardingMasterSkills()
                        .tag(0)
                    OnboardingDailySystem()
                        .tag(1)
                    OnboardingFinalCTA()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule(style: .continuous)
                            .fill(index == page ? AppColors.primary : Color.white.opacity(0.12))
                            .frame(width: index == page ? 28 : 8, height: 6)
                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: page)
                    }
                }
                .padding(.bottom, 14)

                Button {
                    if page < 2 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { page += 1 }
                    } else {
                        appVM.setOnboarded(true)
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text(page < 2 ? "Devam" : "Öğrenmeye Başla")
                            .font(AppTypography.font(16, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(Color(hex: "#001216"))
                    .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .glow(AppColors.primary, radius: 16)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 26)
            }
        }
    }
}

private struct OnboardingMasterSkills: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Neleri")
                        .font(AppTypography.font(36, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    GradientText(
                        "ustalaşacaksın",
                        font: AppTypography.font(36, weight: .bold),
                        gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                }

            Text("Modern mühendislik için tasarlanan yapılandırılmış öğrenme yollarımızla potansiyelini açığa çıkar.")
                .font(AppTypography.font(14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(3)

            VStack(spacing: 12) {
                SkillRow(icon: "square.grid.2x2", title: "Algoritmik Düşünme", subtitle: "Karmaşık mantığı parçalara ayır ve çöz.")
                SkillRow(icon: "puzzlepiece.extension", title: "Problem Çözme", subtitle: "Hataları ayıkla, refactor et, güvenle ilerle.")
                SkillRow(icon: "rectangle.3.group", title: "Gerçek Dünya Senaryoları", subtitle: "Teori değil, pratik ve gerçek problemler.")
                SkillRow(icon: "sparkles", title: "YZ Destekli Kodlama", subtitle: "Daha hızlı üretim için LLM’lerden yararlan.")
            }
            .padding(.top, 10)

            Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
    }
}

private struct SkillRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.18))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.font(15, weight: .semibold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct OnboardingDailySystem: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 40)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 10) {
                        Text("Sadece")
                            .font(AppTypography.font(36, weight: .bold))
                            .foregroundColor(.white)
                        GradientText(
                            "10 dakika",
                            font: AppTypography.font(36, weight: .bold),
                            gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                    Text("günde")
                        .font(AppTypography.font(36, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

            Text("Kalıcı bir alışkanlık oluştur. Zor konuları küçük parçalara bölerek öğren.")
                .font(AppTypography.font(14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .lineSpacing(3)

            VStack(spacing: 18) {
                TimelineRow(step: "Düşün", subtitle: "Isınmak için mantık bulmacaları", xp: "+10 XP", highlight: false)
                TimelineRow(step: "Çöz", subtitle: "Bir bug düzelt veya fonksiyon yaz", xp: "+20 XP", highlight: false)
                TimelineRow(step: "Karar Ver", subtitle: "Mimari trade‑off’lar", xp: "+30 XP", highlight: false)
                TimelineRow(step: "Geliştir (YZ)", subtitle: "Koduna yapay zekâ geri bildirimi", xp: "+50 XP", highlight: true)
            }
            .padding(.top, 8)

            Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 140)
        }
    }
}

private struct TimelineRow: View {
    let step: String
    let subtitle: String
    let xp: String
    let highlight: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(highlight ? AppColors.primary : AppColors.primary.opacity(0.35))
                    .frame(width: 34, height: 34)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .glow(highlight ? AppColors.primary : .clear, radius: 14)
                Rectangle()
                    .fill(AppColors.primary.opacity(0.35))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .opacity(step == "Geliştir (YZ)" ? 0 : 1)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(step)
                        .font(AppTypography.font(18, weight: .bold))
                        .foregroundColor(highlight ? AppColors.primary : .white)
                    Spacer()
                    Text(xp)
                        .font(AppTypography.font(12, weight: .bold))
                        .foregroundColor(highlight ? Color(hex: "#001216") : AppColors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(highlight ? AppColors.primary : AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                }
                Text(subtitle)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

private struct OnboardingFinalCTA: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.08))
                    .frame(width: 220, height: 220)
                    .blur(radius: 40)
                Image(systemName: "flame.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(colors: [AppColors.primary, AppColors.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .glow(AppColors.primary, radius: 18)
            }

                VStack(spacing: 0) {
                Text("Geliştirici")
                    .font(AppTypography.font(34, weight: .bold))
                    .foregroundColor(.white)
                GradientText(
                    "beynini eğit",
                    font: AppTypography.font(34, weight: .bold),
                    gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }

            Text("Tutarlılık yetenekten güçlüdür.\nAlgoritmalar ve sistem tasarımı için günlük serini oluştur.")
                .font(AppTypography.font(14, weight: .medium))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 30)

            Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22)
            .padding(.top, 10)
            .padding(.bottom, 160)
        }
    }
}

private struct GradientText: View {
    let text: String
    let font: Font
    let gradient: LinearGradient

    init(_ text: String, font: Font, gradient: LinearGradient) {
        self.text = text
        self.font = font
        self.gradient = gradient
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(.clear)
            .overlay(gradient.mask(Text(text).font(font)))
    }
}
