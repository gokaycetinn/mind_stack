import Foundation

enum AuthError: LocalizedError {
    case notImplemented
    case invalidCredentials
    case emailNotConfirmed

    var errorDescription: String? {
        switch self {
        case .notImplemented:
            "Authentication provider not configured."
        case .invalidCredentials:
            "Geçersiz e‑posta/şifre."
        case .emailNotConfirmed:
            "E‑posta doğrulanmamış görünüyor. Supabase'de email confirmation açıksa önce e‑postanı doğrula veya test için confirmation'ı kapat."
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    func getSessionUserId() async throws -> UUID? {
        #if canImport(Supabase)
        return try await SupabaseAuthAdapter.currentUserId()
        #else
        return nil
        #endif
    }

    func signIn(email: String, password: String) async throws {
        #if canImport(Supabase)
        do {
            try await SupabaseAuthAdapter.signIn(email: email, password: password)
        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("email") && message.contains("confirm") {
                throw AuthError.emailNotConfirmed
            }
            throw error
        }
        #else
        throw AuthError.notImplemented
        #endif
    }

    func signUp(email: String, password: String) async throws {
        #if canImport(Supabase)
        do {
            try await SupabaseAuthAdapter.signUp(email: email, password: password)
        } catch {
            let message = error.localizedDescription.lowercased()
            if message.contains("email") && message.contains("confirm") {
                throw AuthError.emailNotConfirmed
            }
            throw error
        }
        #else
        try await signIn(email: email, password: password)
        #endif
    }

    func signOut() async throws {
        #if canImport(Supabase)
        try await SupabaseAuthAdapter.signOut()
        #else
        throw AuthError.notImplemented
        #endif
    }
}

#if canImport(Supabase)
import Supabase

@MainActor
enum SupabaseAuthAdapter {
    static func currentUserId() async throws -> UUID? {
        // Önce disk/keychain’deki mevcut oturumu kullan (refresh gerektirmez, daha stabil).
        if let id = SupabaseService.shared.client.auth.currentUser?.id {
            return id
        }
        // Fallback: geçerli session (refresh yapabilir).
        guard let session = try? await SupabaseService.shared.client.auth.session else { return nil }
        return session.user.id
    }

    static func signIn(email: String, password: String) async throws {
        _ = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
    }

    static func signUp(email: String, password: String) async throws {
        _ = try await SupabaseService.shared.client.auth.signUp(email: email, password: password)

        // Eğer Supabase'te "Confirm email" açıksa signUp session döndürmeyebilir ve kullanıcı doğrulanana kadar giriş yapamaz.
        // Demo akışında daha pürüzsüz olması için hemen giriş deniyoruz (Confirm email kapalıysa çalışır).
        _ = try await SupabaseService.shared.client.auth.signIn(email: email, password: password)
    }

    static func signOut() async throws {
        try await SupabaseService.shared.client.auth.signOut()
    }
}
#endif
