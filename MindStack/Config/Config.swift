import Foundation

enum Config {
    static var supabaseURL: String {
        (Bundle.main.infoDictionary?["SUPABASE_URL"] as? String) ?? ""
    }

    static var supabaseAnonKey: String {
        (Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String) ?? ""
    }
}

