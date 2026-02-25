import Foundation

@MainActor
final class TaskService {
    static let shared = TaskService()
    private init() {}

    func getAllTasks() async throws -> [MindTask] {
        // Eski "task" akışı kaldırıldı. Uygulama artık kategori→ders→quiz akışını kullanıyor.
        return []
    }
}
