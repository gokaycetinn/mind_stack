import Foundation

enum LearningServiceError: LocalizedError {
    case notAuthenticated
    case backend(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "Oturum bulunamadı. Lütfen giriş yap."
        case .backend(let message):
            message
        }
    }
}

@MainActor
final class LearningService {
    static let shared = LearningService()
    private init() {}

    struct FeaturedLesson: Identifiable, Codable, Hashable {
        let id: UUID
        let title: String
        let estMinutes: Int
        let sort: Int
        let track: TrackStub

        struct TrackStub: Codable, Hashable {
            let title: String
        }

        enum CodingKeys: String, CodingKey {
            case id
            case title
            case estMinutes = "est_minutes"
            case sort
            case track
        }
    }

    func getCategories() async throws -> [LearningCategory] {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("categories")
                .select()
                .order("sort", ascending: true)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func getFeaturedLessons(limit: Int = 6) async throws -> [FeaturedLesson] {
        #if canImport(Supabase)
        do {
            // PostgREST nested select: track(title)
            return try await SupabaseService.shared.client
                .from("lessons")
                .select("id,title,est_minutes,sort,track:tracks(title)")
                .order("created_at", ascending: false)
                .limit(limit)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func getTracks(categoryId: UUID) async throws -> [LearningTrack] {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("tracks")
                .select()
                .eq("category_id", value: categoryId.uuidString)
                .order("sort", ascending: true)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func getLessons(trackId: UUID) async throws -> [LearningLesson] {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("lessons")
                .select()
                .eq("track_id", value: trackId.uuidString)
                .order("sort", ascending: true)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func getLesson(id: UUID) async throws -> LearningLesson {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("lessons")
                .select()
                .eq("id", value: id.uuidString)
                .single()
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        throw LearningServiceError.backend("Supabase yapılandırılmadı.")
        #endif
    }

    struct UserLessonProgressRow: Codable, Hashable {
        let userId: UUID
        let lessonId: UUID
        let status: String
        let progressPct: Int

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case lessonId = "lesson_id"
            case status
            case progressPct = "progress_pct"
        }
    }

    struct UpsertLessonProgress: Encodable {
        let user_id: String
        let lesson_id: String
        let status: String
        let progress_pct: Int
        let last_seen_at: String?
    }

    func getLessonProgress(lessonIds: [UUID]) async throws -> [UUID: UserLessonProgressRow] {
        #if canImport(Supabase)
        guard let userId = SupabaseService.shared.client.auth.currentUser?.id else {
            throw LearningServiceError.notAuthenticated
        }
        guard !lessonIds.isEmpty else { return [:] }

        // PostgREST in filter requires "(a,b,c)" syntax.
        let inValue = "(" + lessonIds.map(\.uuidString).joined(separator: ",") + ")"

        let rows: [UserLessonProgressRow] = try await SupabaseService.shared.client
            .from("user_lesson_progress")
            .select("user_id,lesson_id,status,progress_pct")
            .eq("user_id", value: userId.uuidString)
            .filter("lesson_id", operator: "in", value: inValue)
            .execute()
            .value

        return Dictionary(uniqueKeysWithValues: rows.map { ($0.lessonId, $0) })
        #else
        return [:]
        #endif
    }

    func upsertLessonProgress(lessonId: UUID, status: String, progressPct: Int) async throws {
        #if canImport(Supabase)
        guard let userId = SupabaseService.shared.client.auth.currentUser?.id else {
            throw LearningServiceError.notAuthenticated
        }

        let payload = UpsertLessonProgress(
            user_id: userId.uuidString,
            lesson_id: lessonId.uuidString,
            status: status,
            progress_pct: max(0, min(100, progressPct)),
            last_seen_at: ISO8601DateFormatter().string(from: Date())
        )

        _ = try await SupabaseService.shared.client
            .from("user_lesson_progress")
            .upsert(payload)
            .execute()
        #endif
    }

    func getQuestions(lessonId: UUID) async throws -> [LearningQuestion] {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("questions")
                .select()
                .eq("lesson_id", value: lessonId.uuidString)
                .order("sort", ascending: true)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    struct QuestionWithOptions: Identifiable, Codable, Hashable {
        let id: UUID
        let lessonId: UUID
        let type: LearningQuestionType
        let prompt: String
        let explanation: String?
        let difficulty: Int
        let xpReward: Int
        let sort: Int
        let createdAt: Date
        let options: [LearningOption]

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
            case options
        }
    }

    func getQuestionsWithOptions(lessonId: UUID) async throws -> [QuestionWithOptions] {
        #if canImport(Supabase)
        do {
            // Nested select: options:question_options(...)
            return try await SupabaseService.shared.client
                .from("questions")
                .select("id,lesson_id,type,prompt,explanation,difficulty,xp_reward,sort,created_at,options:question_options(id,question_id,text,is_correct,sort)")
                .eq("lesson_id", value: lessonId.uuidString)
                .order("sort", ascending: true)
                .order("sort", ascending: true, referencedTable: "question_options")
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func getOptions(questionId: UUID) async throws -> [LearningOption] {
        #if canImport(Supabase)
        do {
            return try await SupabaseService.shared.client
                .from("question_options")
                .select()
                .eq("question_id", value: questionId.uuidString)
                .order("sort", ascending: true)
                .execute()
                .value
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return []
        #endif
    }

    func recordAttempt(questionId: UUID, isCorrect: Bool, chosenOptionIds: [UUID], durationMs: Int?) async throws -> RecordedAttemptResult {
        #if canImport(Supabase)
        do {
            struct Payload: Encodable {
                let p_question_id: String
                let p_is_correct: Bool
                let p_chosen_option_ids: [String]
                let p_duration_ms: Int?
            }

            let payload = Payload(
                p_question_id: questionId.uuidString,
                p_is_correct: isCorrect,
                p_chosen_option_ids: chosenOptionIds.map(\.uuidString),
                p_duration_ms: durationMs
            )

            let rows: [RecordedAttemptResult] = try await SupabaseService.shared.client
                .rpc("record_question_attempt", params: payload)
                .execute()
                .value
            guard let first = rows.first else {
                throw LearningServiceError.backend("İstatistik güncellenemedi.")
            }
            return first
        } catch {
            throw LearningServiceError.backend(error.localizedDescription)
        }
        #else
        return .init(totalXp: 0, currentStreak: 0, bestStreak: 0)
        #endif
    }
}
