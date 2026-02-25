import Foundation

@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    private init() {}

    func getSummary() async throws -> UserSummary {
        #if canImport(Supabase)
        let rows: [UserSummary] = try await SupabaseService.shared.client
            .rpc("get_user_summary")
            .execute()
            .value
        guard let first = rows.first else {
            return .init(totalXp: 0, currentStreak: 0, bestStreak: 0, correct: 0, wrong: 0)
        }
        return first
        #else
        throw AuthError.notImplemented
        #endif
    }

    func getAnalytics(for userId: UUID) async throws -> ProgressAnalytics {
        #if canImport(Supabase)
        struct DailyRow: Codable {
            let day: Date
            let xp: Int
            let correct: Int
            let wrong: Int
        }

        struct Params: Encodable {
            let p_days: Int
        }

        // Son 14 gün: grafik + haftalık streak
        let rows: [DailyRow] = try await SupabaseService.shared.client
            .rpc("get_user_daily_xp", params: Params(p_days: 14))
            .execute()
            .value

        let xpHistory: [XPHistoryEntry] = rows.map { row in
            XPHistoryEntry(id: UUID(), date: row.day, xp: row.xp)
        }

        let last7 = Array(rows.suffix(7))
        let weeklyStreak = last7.map { $0.correct + $0.wrong > 0 }

        return ProgressAnalytics(
            weeklyStreak: weeklyStreak,
            xpHistory: xpHistory,
            skillBreakdown: .init(
                algorithmic: 0,
                problemSolving: 0,
                developerScenario: 0,
                aiReview: 0
            ),
            totalTimeSpentMinutes: 0
        )
        #else
        return .empty
        #endif
    }

    func getTrackBreakdown(limit: Int = 6) async throws -> [TrackBreakdown] {
        #if canImport(Supabase)
        struct Params: Encodable {
            let p_limit: Int
        }

        do {
            return try await SupabaseService.shared.client
                .rpc("get_user_track_breakdown", params: Params(p_limit: max(1, min(20, limit))))
                .execute()
                .value
        } catch {
            // Şema güncellenmediyse fonksiyon bulunamayabilir; UI'da boş liste göster.
            return []
        }
        #else
        throw AuthError.notImplemented
        #endif
    }
}
