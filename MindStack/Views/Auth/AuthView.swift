import SwiftUI

struct AuthView: View {
    @State private var showEmail = false
    @State private var banner: Banner?
    @State private var legalSheet: AuthLegalSheet?

    var body: some View {
        ZStack {
            GradientBackground()

            VStack(spacing: 18) {
                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                        .frame(width: 92, height: 92)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                        .glow(AppColors.primary, radius: 22)

                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(AppColors.primary)
                        .glow(AppColors.primary, radius: 14)
                }

                Text("MindStack")
                    .font(AppTypography.font(40, weight: .bold))
                    .foregroundColor(.clear)
                    .overlay(
                        LinearGradient(colors: [Color.white, Color.white.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                            .mask(Text("MindStack").font(AppTypography.font(40, weight: .bold)))
                    )

                Text("Güvenli geliştirici eğitimi.")
                    .font(AppTypography.font(15, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                VStack(spacing: 12) {
                    AuthButton(style: .apple) { banner = .init(text: "Apple ile giriş yakında.") }
                    AuthButton(style: .google) { banner = .init(text: "Google ile giriş yakında.") }
                    AuthButton(style: .email) { showEmail = true }
                }
                .padding(.horizontal, 22)

                VStack(spacing: 10) {
                    Text("SPAM YOK. GÜRÜLTÜ YOK. SADECE ÖĞRENME.")
                        .font(AppTypography.font(10, weight: .bold))
                        .tracking(3.2)
                        .foregroundColor(Color.white.opacity(0.22))

                    HStack(spacing: 12) {
                        Button("Kullanım Koşulları") { legalSheet = .terms }
                        Text("•").foregroundColor(Color.white.opacity(0.20))
                        Button("Gizlilik Politikası") { legalSheet = .privacy }
                    }
                    .font(AppTypography.font(11, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.30))
                }
                .padding(.bottom, 22)
            }

            if let banner {
                VStack {
                    BannerView(text: banner.text)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) { self.banner = nil }
                    }
                }
            }
        }
        .sheet(isPresented: $showEmail) {
            AuthEmailView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $legalSheet) { sheet in
            LegalView(kind: sheet)
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.9), value: banner != nil)
    }

    private struct Banner: Equatable {
        let text: String
    }

}

private enum AuthButtonStyleKind {
    case apple
    case google
    case email
}

private struct AuthButton: View {
    let style: AuthButtonStyleKind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon
                    .frame(width: 18, height: 18)
                Text(title)
                    .font(AppTypography.font(15, weight: .bold))
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .foregroundColor(fg)
            .background(bg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch style {
        case .apple: "Apple ile Devam Et"
        case .google: "Google ile Devam Et"
        case .email: "E‑posta ile Devam Et"
        }
    }

    private var fg: Color {
        switch style {
        case .apple: Color(hex: "#0B1121")
        case .google: .white.opacity(0.92)
        case .email: .white.opacity(0.82)
        }
    }

    private var bg: Color {
        switch style {
        case .apple: .white
        case .google: Color.white.opacity(0.10)
        case .email: Color.white.opacity(0.07)
        }
    }

    private var borderOpacity: CGFloat {
        switch style {
        case .apple: 0.55
        case .google: 0.12
        case .email: 0.10
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch style {
        case .apple:
            Image(systemName: "apple.logo")
        case .google:
            Image(systemName: "g.circle.fill")
                .foregroundColor(.white.opacity(0.9))
        case .email:
            Image(systemName: "envelope")
        }
    }
}

private struct BannerView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppTypography.font(13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.black.opacity(0.35), in: Capsule(style: .continuous))
            .overlay(
                Capsule(style: .continuous)
                    .stroke(AppColors.primary.opacity(0.22), lineWidth: 1)
            )
            .padding(.top, 14)
    }
}

private struct LegalView: View {
    let kind: AuthLegalSheet
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
        switch kind {
        case .terms: "Kullanım Koşulları"
        case .privacy: "Gizlilik Politikası"
        }
    }

    private var bodyText: String {
        switch kind {
        case .terms:
            "Demo build: Bu ekran yalnızca tasarım ve akış kontrolü için eklenmiştir. Daha sonra gerçek içerik/URL bağlanacaktır."
        case .privacy:
            "Demo build: Bu ekran yalnızca tasarım ve akış kontrolü için eklenmiştir. Daha sonra gerçek içerik/URL bağlanacaktır."
        }
    }
}

private enum AuthLegalSheet: String, Identifiable {
    case terms
    case privacy

    var id: String { rawValue }
}
