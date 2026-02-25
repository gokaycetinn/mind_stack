import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appVM: AppViewModel
    @State private var pushNotifications = true
    @State private var performanceMode = false
    @State private var sheet: ProfileSheet?

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    topBar
                    profileHeader
                    statsGrid
                    settings
                    dangerZone
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 120)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .sheet(item: $sheet) { sheet in
            ProfileSheetView(sheet: sheet)
        }
    }

    private var topBar: some View {
        HStack {
            Text("Profil")
                .font(AppTypography.font(16, weight: .bold))
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
    }

    private var profileHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(colors: [AppColors.primary, Color.white.opacity(0.0)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 4
                    )
                    .frame(width: 118, height: 118)
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 106, height: 106)

                Text("🙂")
                    .font(.system(size: 40))

                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 28, height: 28)
                    .overlay(Image(systemName: "pencil").font(.system(size: 12, weight: .bold)).foregroundColor(Color(hex: "#001216")))
                    .offset(x: 42, y: 38)
            }

            Text(appVM.user?.name ?? "Geliştirici")
                .font(AppTypography.font(24, weight: .heavy))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(AppColors.primary)
                Text(appVM.getCurrentLevel().name.uppercased())
                    .font(AppTypography.font(11, weight: .bold))
                    .tracking(2.0)
                    .foregroundColor(AppColors.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.primary.opacity(0.12), in: Capsule(style: .continuous))
            .overlay(Capsule(style: .continuous).stroke(AppColors.primary.opacity(0.18), lineWidth: 1))

            VStack(spacing: 8) {
                HStack {
                    Text("SEVİYE 12")
                    Spacer()
                    Text("\(appVM.user?.xp ?? 0) XP")
                }
                .font(AppTypography.font(10, weight: .bold))
                .tracking(1.8)
                .foregroundColor(AppColors.textTertiary)

                ZStack(alignment: .leading) {
                    Capsule(style: .continuous).fill(Color.white.opacity(0.08)).frame(height: 6)
                    Capsule(style: .continuous).fill(AppColors.primary).frame(width: 0.62 * 220, height: 6).glow(AppColors.primary, radius: 10)
                }
                .frame(maxWidth: 220)
            }
            .padding(.top, 8)
        }
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            StatMiniCard(value: formattedXP(appVM.summary?.totalXp ?? appVM.user?.totalXp ?? 0), label: "TOPLAM XP", icon: "bolt.fill", tint: AppColors.primary)
            StatMiniCard(value: "\(appVM.summary?.currentStreak ?? appVM.user?.streak ?? 0)", label: "GÜNLÜK SERİ", icon: "flame.fill", tint: .orange)
            StatMiniCard(value: "\(totalAnswered)", label: "CEVAP", icon: "checkmark.seal.fill", tint: Color(hex: "#34D399"))
        }
    }

    private var totalAnswered: Int {
        (appVM.summary?.correct ?? 0) + (appVM.summary?.wrong ?? 0)
    }

    private func formattedXP(_ xp: Int) -> String {
        if xp >= 1000 {
            return String(format: "%.1fk", Double(xp) / 1000.0)
        }
        return "\(xp)"
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AYARLAR & TERCİHLER")
                .font(AppTypography.font(11, weight: .bold))
                .tracking(2.2)
                .foregroundColor(AppColors.textTertiary)
                .padding(.leading, 4)

            VStack(spacing: 0) {
                ToggleRow(icon: "bell.fill", title: "Bildirimler", isOn: $pushNotifications)
                Divider().overlay(Color.white.opacity(0.06))
                ToggleRow(icon: "speedometer", title: "Performans Modu", isOn: $performanceMode)
                Divider().overlay(Color.white.opacity(0.06))
                LinkRow(icon: "person.fill", title: "Hesap Detayları") { sheet = .accountDetails }
                Divider().overlay(Color.white.opacity(0.06))
                LinkRow(icon: "lock.fill", title: "Gizlilik ve Güvenlik") { sheet = .privacySecurity }
            }
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .padding(.top, 4)
    }

    private var dangerZone: some View {
        VStack(spacing: 10) {
            Button(role: .destructive) {
                Task { await appVM.signOut() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Çıkış Yap")
                        .font(AppTypography.font(14, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundColor(Color.red.opacity(0.95))
                .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.red.opacity(0.22), lineWidth: 1))
            }

            Text("MindStack v2.4.0 (Build 892)")
                .font(AppTypography.font(10, weight: .semibold))
                .foregroundColor(AppColors.textTertiary.opacity(0.7))
        }
        .padding(.top, 4)
    }
}

private struct StatMiniCard: View {
    let value: String
    let label: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.14))
                    .frame(width: 34, height: 34)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(tint)
            }
            Text(value)
                .font(AppTypography.font(16, weight: .heavy))
                .foregroundColor(.white)
            Text(label)
                .font(AppTypography.font(10, weight: .bold))
                .tracking(2.0)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

private struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.textSecondary)
            }
            Text(title)
                .font(AppTypography.font(14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

private struct LinkRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                }
                Text(title)
                    .font(AppTypography.font(14, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.22))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

private enum ProfileSheet: String, Identifiable {
    case accountDetails
    case privacySecurity
    case about

    var id: String { rawValue }
}

private struct ProfileSheetView: View {
    let sheet: ProfileSheet
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

                        Text(bodyText)
                            .font(AppTypography.font(14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                            .lineSpacing(4)
                            .padding(.top, 6)

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
        case .accountDetails: "Hesap Detayları"
        case .privacySecurity: "Gizlilik ve Güvenlik"
        case .about: "Hakkında"
        }
    }

    private var bodyText: String {
        switch sheet {
        case .accountDetails:
            "Yakında: Supabase üzerinde profil bilgileri (kullanıcı adı, avatar, tercih edilen kategoriler) saklanacak ve burada yönetilebilecek."
        case .privacySecurity:
            "Yakında: şifre değişikliği, oturum cihazları ve güvenlik ayarları Supabase/Auth ile tamamlanacak."
        case .about:
            "MindStack SwiftUI.\n\nBu sürüm Supabase ile canlı içerik ve quiz akışını kullanır."
        }
    }
}
