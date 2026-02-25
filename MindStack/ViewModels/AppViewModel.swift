import Foundation

@MainActor
final class AppViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var isAuthenticated: Bool = false
    @Published var user: User?
    @Published var tasks: [MindTask] = []
    @Published var analytics: ProgressAnalytics = .empty
    @Published var summary: UserSummary?
    @Published var trackBreakdown: [TrackBreakdown] = []

    init() {
        Task { await initialize() }
    }

    func initialize() async {
        isLoading = true
        defer { isLoading = false }

        do {
            if let userId = try await AuthService.shared.getSessionUserId() {
                isAuthenticated = true
                await loadUser(userId: userId)
                await loadTasks()
                await loadAnalytics()
            } else {
                isAuthenticated = false
                user = nil
                tasks = []
                analytics = .empty
                summary = nil
                trackBreakdown = []
            }
        } catch {
            isAuthenticated = false
        }
    }

    func setOnboarded(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "isOnboarded")
    }

    func signOut() async {
        try? await AuthService.shared.signOut()
        await initialize()
    }

    func getCurrentLevel() -> (name: String, progress: Int, xpToNext: Int, levelId: Int) {
        let xp = user?.xp ?? 0
        let level = Constants.levels.first { xp >= $0.minXp && xp < $0.maxXp } ?? Constants.levels.last!
        let span = max(1, level.maxXp - level.minXp)
        let progress = Int((Double(xp - level.minXp) / Double(span)) * 100)
        let xpToNext = max(0, level.maxXp - xp)
        return (level.name, min(100, max(0, progress)), xpToNext, level.id)
    }

    func markTaskCompleted(_ taskId: UUID, xpGained: Int) {
        tasks = tasks.map { t in
            var copy = t
            if copy.id == taskId { copy.isCompleted = true }
            return copy
        }

        if var u = user {
            u.xp += xpGained
            u.totalXp += xpGained
            user = u
        }
    }

    private func loadUser(userId: UUID) async {
        #if canImport(Supabase)
        // currentSession, refresh çağrısı yapmadığı için daha stabil.
        let auth = SupabaseService.shared.client.auth
        let session = if let current = auth.currentSession {
            current
        } else {
            try? await auth.session
        }
        guard let session else { return }

        let email = session.user.email ?? ""
        let displayName = email.split(separator: "@").first.map(String.init) ?? "Geliştirici"

        let stats = await fetchOrCreateStats(userId: userId)
        user = User(
            id: userId,
            email: email,
            name: displayName,
            avatarUrl: nil,
            xp: stats.totalXp,
            totalXp: stats.totalXp,
            streak: stats.currentStreak,
            lastActivityDate: stats.lastActiveAt
        )
        #else
        user = nil
        #endif
    }

    private func loadTasks() async {
        tasks = (try? await TaskService.shared.getAllTasks()) ?? []
    }

    private func loadAnalytics() async {
        guard let id = user?.id else { return }
        analytics = (try? await AnalyticsService.shared.getAnalytics(for: id)) ?? .empty
        summary = (try? await AnalyticsService.shared.getSummary())
        trackBreakdown = (try? await AnalyticsService.shared.getTrackBreakdown(limit: 6)) ?? []

        if var u = user, let summary {
            u.totalXp = summary.totalXp
            u.xp = summary.totalXp
            u.streak = summary.currentStreak
            user = u
        }
    }

    #if canImport(Supabase)
    private struct UserStatsRow: Codable {
        let userId: UUID
        let totalXp: Int
        let currentStreak: Int
        let bestStreak: Int
        let lastActiveAt: Date?

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case totalXp = "total_xp"
            case currentStreak = "current_streak"
            case bestStreak = "best_streak"
            case lastActiveAt = "last_active_at"
        }
    }

    private struct UserStatsInsert: Encodable {
        let user_id: String
        let total_xp: Int
        let current_streak: Int
        let best_streak: Int
        let last_active_at: String?
    }

    private func fetchOrCreateStats(userId: UUID) async -> UserStatsRow {
        if let row: UserStatsRow = try? await SupabaseService.shared.client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
            .value
        {
            return row
        }

        let insert = UserStatsInsert(
            user_id: userId.uuidString,
            total_xp: 0,
            current_streak: 0,
            best_streak: 0,
            last_active_at: nil
        )

        _ = try? await SupabaseService.shared.client
            .from("user_stats")
            .insert(insert)
            .execute()

        if let row: UserStatsRow = try? await SupabaseService.shared.client
            .from("user_stats")
            .select()
            .eq("user_id", value: userId.uuidString)
            .single()
            .execute()
            .value
        {
            return row
        }

        return .init(userId: userId, totalXp: 0, currentStreak: 0, bestStreak: 0, lastActiveAt: nil)
    }
    #endif
}
