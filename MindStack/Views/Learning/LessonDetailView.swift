import SwiftUI

struct LessonDetailView: View {
    let lesson: LearningLesson

    var body: some View {
        LessonPlayerView(lesson: lesson)
    }
}
