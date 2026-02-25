import Foundation

@MainActor
final class LearningViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var categories: [LearningCategory] = []
    @Published var errorMessage: String?

    private var tracksCache: [UUID: [LearningTrack]] = [:]
    private var lessonsCache: [UUID: [LearningLesson]] = [:]

    func loadCategories(force: Bool = false) async {
        if !categories.isEmpty && !force { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            categories = try await LearningService.shared.getCategories()
        } catch {
            errorMessage = error.localizedDescription
            categories = []
        }
    }

    func tracks(for category: LearningCategory) async -> [LearningTrack] {
        if let cached = tracksCache[category.id] { return cached }
        do {
            let tracks = try await LearningService.shared.getTracks(categoryId: category.id)
            tracksCache[category.id] = tracks
            return tracks
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    func lessons(for track: LearningTrack) async -> [LearningLesson] {
        if let cached = lessonsCache[track.id] { return cached }
        do {
            let lessons = try await LearningService.shared.getLessons(trackId: track.id)
            lessonsCache[track.id] = lessons
            return lessons
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}

