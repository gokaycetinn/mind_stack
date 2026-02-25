import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var sheet: AnalyticsSheet?

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    header
                    weeklyMomentum
                    overview
                    insights
                    xpVelocity
                    milestones
                    topicBreakdown
                    topPerformer
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("Analiz")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $sheet) { sheet in
            AnalyticsSheetView(sheet: sheet)
        }
    }

    private var header: some View {
        HStack {
            Text("Analiz")
                .font(AppTypography.font(18, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button {
                sheet = .about
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(AppColors.textSecondary)
                    .padding(10)
                    .background(Color.white.opacity(0.06), in: Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }

    private var weeklyMomentum: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("HAFTALIK TEMPO")
                        .font(AppTypography.font(11, weight: .bold))
                        .tracking(2.2)
                        .foregroundColor(AppColors.textTertiary)
                    Text("Akışı canlı tut.")
                        .font(AppTypography.font(13, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill").foregroundColor(AppColors.primary)
                    Text("\(appVM.user?.streak ?? 0)")
                        .font(AppTypography.font(18, weight: .heavy))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                .overlay(Capsule(style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
            }

            HStack {
                let labels = ["P","S","Ç","P","C","C","P"]
                ForEach(Array(labels.enumerated()), id: \.offset) { idx, label in
                    VStack(spacing: 10) {
                        Circle()
                            .fill(appVM.analytics.weeklyStreak[safe: idx] == true ? AppColors.primary : Color.white.opacity(0.12))
                            .frame(width: 8, height: 8)
                            .glow(appVM.analytics.weeklyStreak[safe: idx] == true ? AppColors.primary : .clear, radius: 10)
                        Text(label)
                            .font(AppTypography.font(12, weight: .semibold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)
        }
    }

    private var xpVelocity: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("XP HIZI")
                .font(AppTypography.font(11, weight: .bold))
                .tracking(2.2)
                .foregroundColor(AppColors.textTertiary)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(weeklyXP)")
                    .font(AppTypography.font(36, weight: .heavy))
                    .foregroundColor(.white)
                Text(xpDeltaText)
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(AppColors.primary)
                Spacer()
                Text("Bu Hafta")
                    .font(AppTypography.font(12, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
            }

            Chart(appVM.analytics.xpHistory) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("XP", item.xp)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(AppColors.primary)
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("XP", item.xp)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary.opacity(0.25), AppColors.primary.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 170)
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
    }

    private var weeklyXP: Int {
        let last7 = appVM.analytics.xpHistory.suffix(7)
        return last7.reduce(0) { $0 + $1.xp }
    }

    private var xpDeltaText: String {
        let history = appVM.analytics.xpHistory
        guard history.count >= 14 else { return "—" }
        let first7 = history.prefix(7).reduce(0) { $0 + $1.xp }
        let last7 = history.suffix(7).reduce(0) { $0 + $1.xp }
        let base = max(1, first7)
        let pct = Int(((Double(last7 - first7) / Double(base)) * 100.0).rounded())
        let sign = pct > 0 ? "+" : ""
        return "\(sign)\(pct)%"
    }

    private var milestones: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MİLAT TAŞLARI")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
                Button("Tümünü Gör") {
                    sheet = .milestones
                }
                .font(AppTypography.font(12, weight: .bold))
                .foregroundColor(AppColors.primary)
            }

            HStack(spacing: 14) {
                MilestoneIcon(title: "Mülakat\nHazır", systemImage: "briefcase.fill", tint: Color(hex: "#38BDF8"))
                MilestoneIcon(title: "Mantık\nUstası", systemImage: "brain.head.profile", tint: Color(hex: "#C084FC"))
                MilestoneIcon(title: "YZ\nFarkındalık", systemImage: "sparkles", tint: Color(hex: "#FBBF24"))
            }
        }
    }

    private var overview: some View {
        let correct = appVM.summary?.correct ?? 0
        let wrong = appVM.summary?.wrong ?? 0
        let total = max(1, correct + wrong)
        let accuracy = Double(correct) / Double(total)

        return VStack(alignment: .leading, spacing: 12) {
            Text("GENEL DURUM")
                .font(AppTypography.font(11, weight: .bold))
                .tracking(2.2)
                .foregroundColor(AppColors.textTertiary)

            HStack(spacing: 12) {
                StatPill(title: "Toplam XP", value: "\(appVM.summary?.totalXp ?? 0)", systemImage: "bolt.fill", tint: AppColors.primary)
                StatPill(title: "Seri", value: "\(appVM.summary?.currentStreak ?? 0)", systemImage: "flame.fill", tint: .orange.opacity(0.95))
            }

            HStack(spacing: 12) {
                StatPill(title: "Doğru", value: "\(correct)", systemImage: "checkmark.circle.fill", tint: AppColors.primary)
                StatPill(title: "Yanlış", value: "\(wrong)", systemImage: "xmark.circle.fill", tint: AppColors.error)
                StatPill(title: "Başarı", value: "\(Int((accuracy * 100).rounded()))%", systemImage: "target", tint: AppColors.purple)
            }
        }
    }

    private var insights: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("İÇGÖRÜLER")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
                Button {
                    sheet = .about
                } label: {
                    Text("Nasıl hesaplanır?")
                        .font(AppTypography.font(12, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if insightCards.isEmpty {
                Text("Henüz yeterli veri yok. 1–2 ders çöz ve tekrar bak.")
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(14)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(insightCards.prefix(3)) { item in
                        InsightCard(item: item)
                    }
                }
            }
        }
    }

    private var topicBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("KONU DAĞILIMI")
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.2)
                    .foregroundColor(AppColors.textTertiary)
                Spacer()
                if appVM.trackBreakdown.isEmpty {
                    Text("Veri yok")
                        .font(AppTypography.font(12, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.06), in: Capsule(style: .continuous))
                }
            }

            if !appVM.trackBreakdown.isEmpty {
                VStack(spacing: 10) {
                    ForEach(appVM.trackBreakdown.prefix(5)) { item in
                        TopicRow(item: item)
                    }
                }
            }
        }
    }

    private var topPerformer: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(AppColors.primary.opacity(0.12))
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text("İlk %5 Performans")
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.white)
                Text("Tutarlılık algoritman optimize. Ortalama öğrenme eğrisinin belirgin şekilde üzerindesin.")
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private enum AnalyticsSheet: String, Identifiable {
    case milestones
    case about
    var id: String { rawValue }
}

private struct AnalyticsSheetView: View {
    let sheet: AnalyticsSheet
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(title)
                            .font(AppTypography.font(26, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.top, 10)

                        switch sheet {
                        case .milestones:
                            VStack(spacing: 10) {
                                MilestoneRow(title: "Mülakat Hazır", subtitle: "1 haftada 10 görev tamamla", icon: "briefcase.fill", tint: Color(hex: "#38BDF8"))
                                MilestoneRow(title: "Mantık Ustası", subtitle: "20 algoritmik bulmaca çöz", icon: "brain.head.profile", tint: Color(hex: "#C084FC"))
                                MilestoneRow(title: "YZ Farkındalık", subtitle: "5 yapay zekâ inceleme görevi bitir", icon: "sparkles", tint: Color(hex: "#FBBF24"))
                            }
                            .padding(.top, 8)
                        case .about:
                            Text("İçgörüler; doğru/yanlış oranı, son günlerdeki aktivite ve konu bazlı performansına göre üretilir. Daha çok ders çözdükçe öneriler daha isabetli olur.")
                                .font(AppTypography.font(14, weight: .medium))
                                .foregroundColor(AppColors.textSecondary)
                                .lineSpacing(4)
                                .padding(.top, 6)
                        }

                        Spacer(minLength: 60)
                    }
                    .padding(18)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.10), lineWidth: 1))
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 30)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }

    private var title: String {
        switch sheet {
        case .milestones: "Milat Taşları"
        case .about: "Analiz Hakkında"
        }
    }
}

private struct TopicRow: View {
    let item: TrackBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.trackTitle)
                        .font(AppTypography.font(14, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(item.categoryTitle)
                        .font(AppTypography.font(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
                Spacer()
                Text("\(Int((item.accuracy * 100).rounded()))%")
                    .font(AppTypography.font(12, weight: .bold))
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
            }

            GeometryReader { g in
                let total = max(1, item.correctCount + item.wrongCount)
                let correctW = (CGFloat(item.correctCount) / CGFloat(total)) * g.size.width
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    Capsule(style: .continuous)
                        .fill(AppColors.primary)
                        .frame(width: max(12, correctW), height: 8)
                        .glow(AppColors.primary, radius: 10)
                }
            }
            .frame(height: 8)

            Text("Doğru: \(item.correctCount) • Yanlış: \(item.wrongCount)")
                .font(AppTypography.font(11, weight: .semibold))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct StatPill: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(tint.opacity(0.16))
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(tint)
            }
            .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.font(11, weight: .bold))
                    .foregroundColor(AppColors.textTertiary)
                Text(value)
                    .font(AppTypography.font(16, weight: .heavy))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct InsightCardModel: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let systemImage: String
    let tint: Color
}

private extension AnalyticsView {
    var insightCards: [InsightCardModel] {
        let correct = appVM.summary?.correct ?? 0
        let wrong = appVM.summary?.wrong ?? 0
        let attempts = correct + wrong

        var cards: [InsightCardModel] = []

        if attempts < 3 {
            cards.append(.init(
                title: "Isınma Önerisi",
                body: "Bugün 1 kısa ders tamamla. Sonra başarı oranını ve konu dağılımını burada net göreceksin.",
                systemImage: "sparkles",
                tint: AppColors.primary
            ))
            return cards
        }

        // Zayıf konu önerisi
        if let weakest = appVM.trackBreakdown
            .filter({ ($0.correctCount + $0.wrongCount) >= 4 })
            .min(by: { $0.accuracy < $1.accuracy })
        {
            if weakest.accuracy < 0.65 {
                cards.append(.init(
                    title: "Odak Alanı: \(weakest.trackTitle)",
                    body: "\(weakest.categoryTitle) içinde bu konuda başarı oranı düşük. 1 dersi tekrar oku ve aynı konudan 5 soru çöz.",
                    systemImage: "target",
                    tint: .orange.opacity(0.95)
                ))
            } else {
                cards.append(.init(
                    title: "Güçlü Alan: \(weakest.trackTitle)",
                    body: "Konu bazlı performansın dengeli. Yeni bir track’e geçerek zorluğu artırabilirsin.",
                    systemImage: "checkmark.seal.fill",
                    tint: AppColors.primary
                ))
            }
        }

        // Genel hata eğilimi
        if wrong > correct {
            cards.append(.init(
                title: "Tekrar Modu",
                body: "Yanlış sayın doğru sayını geçti. Bugün 10 dakikayı “tekrar”a ayır: yanlış yaptığın konudan bir ders seç ve quiz’i tekrar çöz.",
                systemImage: "arrow.counterclockwise",
                tint: AppColors.purple
            ))
        } else {
            cards.append(.init(
                title: "İyi Gidiyorsun",
                body: "Doğru oranı iyi. Bir sonraki adım: daha zor sorular için yeni bir track’e geç.",
                systemImage: "chart.line.uptrend.xyaxis",
                tint: AppColors.primary
            ))
        }

        // Tutarlılık (son 3 gün)
        let last3 = appVM.analytics.xpHistory.suffix(3)
        let activeDays = last3.filter { $0.xp > 0 }.count
        if activeDays <= 1 {
            cards.append(.init(
                title: "Tutarlılık İpucu",
                body: "Son günlerde tempo düşük. Günlük hedefini küçük tut (örn. 30 XP) ve seri oluştur.",
                systemImage: "flame.fill",
                tint: .orange.opacity(0.95)
            ))
        }

        return cards
    }
}

private struct InsightCard: View {
    let item: InsightCardModel

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(item.tint.opacity(0.16))
                Image(systemName: item.systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(item.tint)
                    .glow(item.tint, radius: 10)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.white)
                Text(item.body)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .lineSpacing(3)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct MilestoneRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(tint)
                    .glow(tint, radius: 10)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.font(14, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(AppTypography.font(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct MilestoneIcon: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 72, height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )

                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(tint)
                    .glow(tint, radius: 10)
            }
            Text(title.uppercased())
                .font(AppTypography.font(10, weight: .bold))
                .tracking(2.0)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
