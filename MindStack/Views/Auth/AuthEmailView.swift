import SwiftUI

struct AuthEmailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appVM: AppViewModel

    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(isLogin ? "Giriş Yap" : "Hesap Oluştur")
                            .font(AppTypography.font(28, weight: .bold))
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Hesabın yoksa kaydol, varsa giriş yap.")
                                    .font(AppTypography.font(12, weight: .semibold))
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                            }

                            LabeledField(title: "E‑posta / Kullanıcı Adı") {
                                TextField("ad@domain.com", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .textContentType(.username)
                            }

                            LabeledField(title: "Şifre") {
                                SecureField("Şifren", text: $password)
                                    .textContentType(.password)
                            }

                            if let errorMessage {
                                Text(errorMessage)
                                    .font(AppTypography.font(12, weight: .semibold))
                                    .foregroundColor(AppColors.error)
                                    .padding(.top, 2)
                            }

                            Button {
                                Task { await submit() }
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView().tint(Color(hex: "#001216"))
                                    } else {
                                        Text(isLogin ? "Giriş Yap" : "Hesap Oluştur")
                                            .font(AppTypography.font(16, weight: .bold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundColor(Color(hex: "#001216"))
                                .background(AppColors.primary, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .glow(AppColors.primary, radius: 16)
                            }
                            .disabled(isLoading || email.isEmpty || password.isEmpty)
                            .padding(.top, 6)
                        }
                        .padding(18)
                        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )

                        Button(isLogin ? "Hesabın yok mu? Kaydol" : "Zaten hesabın var mı? Giriş yap") {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                                isLogin.toggle()
                                errorMessage = nil
                            }
                        }
                        .font(AppTypography.font(13, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.top, 4)

                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func submit() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            if isLogin {
                try await AuthService.shared.signIn(email: email, password: password)
            } else {
                try await AuthService.shared.signUp(email: email, password: password)
            }
            await appVM.initialize()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct LabeledField<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(AppTypography.font(11, weight: .bold))
                .tracking(2.2)
                .foregroundColor(AppColors.textTertiary)

            content
                .font(AppTypography.font(16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppColors.primary.opacity(0.16), lineWidth: 1)
                )
        }
    }
}
