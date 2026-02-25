import Foundation

#if canImport(Supabase)
import Supabase

@MainActor
final class SupabaseService {
    static let shared = SupabaseService()
    let client: SupabaseClient

    private init() {
        guard let url = URL(string: Config.supabaseURL), !Config.supabaseAnonKey.isEmpty else {
            fatalError("Supabase configuration missing. Set SUPABASE_URL and SUPABASE_ANON_KEY in Info.plist.")
        }

        // Not: Bazı geliştirme ortamlarında (özellikle code signing kapalıyken) Keychain yazımı başarısız olabiliyor.
        // Bu durumda oturum saklanamadığı için uygulama her seferinde Auth ekranına döner.
        // UI/akış testleri için DEBUG'da UserDefaults tabanlı storage kullanıyoruz.
        #if DEBUG
        let options = SupabaseClientOptions(
            auth: .init(
                storage: UserDefaultsAuthStorage(),
                emitLocalSessionAsInitialSession: true
            )
        )
        client = SupabaseClient(supabaseURL: url, supabaseKey: Config.supabaseAnonKey, options: options)
        #else
        client = SupabaseClient(supabaseURL: url, supabaseKey: Config.supabaseAnonKey)
        #endif
    }
}

#if DEBUG
private struct UserDefaultsAuthStorage: AuthLocalStorage {
    func store(key: String, value: Data) throws {
        UserDefaults.standard.set(value, forKey: key)
    }

    func retrieve(key: String) throws -> Data? {
        UserDefaults.standard.data(forKey: key)
    }

    func remove(key: String) throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
#endif
#else
@MainActor
final class SupabaseService {
    static let shared = SupabaseService()
    private init() {}
}
#endif
