import Foundation

struct LearningCategory: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String?
    let sort: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case sort
        case createdAt = "created_at"
    }
}

struct LearningTrack: Identifiable, Codable, Hashable {
    let id: UUID
    let categoryId: UUID
    let title: String
    let description: String?
    let level: String?
    let sort: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case title
        case description
        case level
        case sort
        case createdAt = "created_at"
    }
}

struct LearningLesson: Identifiable, Codable, Hashable {
    let id: UUID
    let trackId: UUID
    let title: String
    let contentMd: String
    let estMinutes: Int
    let sort: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case trackId = "track_id"
        case title
        case contentMd = "content_md"
        case estMinutes = "est_minutes"
        case sort
        case createdAt = "created_at"
    }
}

enum LearningQuestionType: String, Codable {
    case singleChoice = "single_choice"
    case multiChoice = "multi_choice"
    case trueFalse = "true_false"
}

struct LearningQuestion: Identifiable, Codable, Hashable {
    let id: UUID
    let lessonId: UUID
    let type: LearningQuestionType
    let prompt: String
    let explanation: String?
    let difficulty: Int
    let xpReward: Int
    let sort: Int
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case lessonId = "lesson_id"
        case type
        case prompt
        case explanation
        case difficulty
        case xpReward = "xp_reward"
        case sort
        case createdAt = "created_at"
    }
}

struct LearningOption: Identifiable, Codable, Hashable {
    let id: UUID
    let questionId: UUID
    let text: String
    let isCorrect: Bool
    let sort: Int

    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case text
        case isCorrect = "is_correct"
        case sort
    }
}

struct RecordedAttemptResult: Codable, Hashable {
    let totalXp: Int
    let currentStreak: Int
    let bestStreak: Int

    enum CodingKeys: String, CodingKey {
        case totalXp = "total_xp"
        case currentStreak = "current_streak"
        case bestStreak = "best_streak"
    }
}

