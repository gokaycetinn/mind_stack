import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var email: String
    var name: String
    var avatarUrl: String?
    var xp: Int
    var totalXp: Int
    var streak: Int
    var lastActivityDate: Date?
}

enum TaskCategory: String, Codable, CaseIterable {
    case algorithmicThinking = "algorithmic_thinking"
    case problemSolving = "problem_solving"
    case developerScenario = "developer_scenario"
    case aiReview = "ai_review"
}

struct MindTask: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let category: TaskCategory
    let durationMinutes: Int
    let xpReward: Int
    let colorHex: String
    let iconSystemName: String
    var isLocked: Bool
    var isCompleted: Bool
}

struct XPHistoryEntry: Identifiable, Codable {
    let id: UUID
    let date: Date
    let xp: Int
}

struct SkillBreakdown: Codable {
    var algorithmic: Int
    var problemSolving: Int
    var developerScenario: Int
    var aiReview: Int
}

struct ProgressAnalytics: Codable {
    var weeklyStreak: [Bool]
    var xpHistory: [XPHistoryEntry]
    var skillBreakdown: SkillBreakdown
    var totalTimeSpentMinutes: Int
}

extension ProgressAnalytics {
    static let empty = ProgressAnalytics(
        weeklyStreak: Array(repeating: false, count: 7),
        xpHistory: [],
        skillBreakdown: .init(algorithmic: 0, problemSolving: 0, developerScenario: 0, aiReview: 0),
        totalTimeSpentMinutes: 0
    )
}

struct UserSummary: Codable, Hashable {
    let totalXp: Int
    let currentStreak: Int
    let bestStreak: Int
    let correct: Int
    let wrong: Int

    enum CodingKeys: String, CodingKey {
        case totalXp = "total_xp"
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
        case correct
        case wrong
    }
}

struct TrackBreakdown: Identifiable, Codable, Hashable {
    let trackId: UUID
    let trackTitle: String
    let categoryTitle: String
    let correctCount: Int
    let wrongCount: Int
    let accuracy: Double

    var id: UUID { trackId }

    enum CodingKeys: String, CodingKey {
        case trackId = "track_id"
        case trackTitle = "track_title"
        case categoryTitle = "category_title"
        case correctCount = "correct_count"
        case wrongCount = "wrong_count"
        case accuracy
    }
}
