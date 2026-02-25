# MindStack - Swift/SwiftUI Implementation Guide

> **Kapsamlı Yönerge**: Bu belge, MindStack uygulamasının Swift/SwiftUI ile sıfırdan geliştirilmesi için gereken tüm bilgileri içerir. Bir AI agent bu belgeyi okuyarak uygulamayı tamamen oluşturabilmelidir.

---

## 📋 İçindekiler

1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Teknoloji Stack](#teknoloji-stack)
3. [Proje Yapısı](#proje-yapısı)
4. [Backend & Supabase Kurulumu](#backend--supabase-kurulumu)
5. [Veri Modelleri](#veri-modelleri)
6. [State Management](#state-management)
7. [Navigation & Routing](#navigation--routing)
8. [Tema & Tasarım Sistemi](#tema--tasarım-sistemi)
9. [Ekranlar (Views)](#ekranlar-views)
10. [UI Bileşenleri](#ui-bileşenleri)
11. [Servisler](#servisler)
12. [Animasyonlar](#animasyonlar)
13. [Dependencies & SPM](#dependencies--spm)
14. [Kurulum Adımları](#kurulum-adımları)

---

## 1. Proje Genel Bakış

### Uygulama Tanımı
**MindStack** - Geliştiricilerin problem çözme ve algoritmik düşünme becerilerini günlük eğitim oturumlarıyla geliştirmelerine yardımcı olan bir mobil eğitim platformudur.

### Ana Özellikler
- ✅ Kullanıcı Kimlik Doğrulama (Email/Password)
- ✅ Dinamik Görev Sistemi (Task-based Learning)
- ✅ Eğitim İçeriği (Lessons & Questions)
- ✅ İlerleme Takibi (XP, Level, Streak)
- ✅ Analitik Dashboard
- ✅ Gamification (XP sistemi, günlük seriler)
- ✅ 4 Görev Kategorisi:
  - Algorithmic Thinking
  - Problem Solving
  - Developer Scenarios
  - AI Code Review

### Hedef Platform
- **iOS 16.0+**
- **SwiftUI** ile modern, native iOS deneyimi
- **Dark Mode** öncelikli tasarım

---

## 2. Teknoloji Stack

### Frontend
```swift
// Core
- SwiftUI (UI Framework)
- Combine (Reactive Programming)
- Swift Concurrency (async/await)

// Navigation
- NavigationStack (iOS 16+)
- Sheet & FullScreenCover

// Storage
- UserDefaults (Onboarding state)
- Keychain (Secure token storage)
```

### Backend & Services
```
- Supabase (Backend-as-a-Service)
  - PostgreSQL Database
  - Authentication (Email/Password)
  - Row Level Security (RLS)
  - Real-time subscriptions
```

### Dependencies (Swift Package Manager)
```swift
dependencies: [
    // Supabase Swift SDK
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0"),
    
    // Optional: Charts (iOS 16+)
    // Built-in SwiftUI Charts
]
```

---

## 3. Proje Yapısı

```
MindStack/
├── MindStackApp.swift                  # App entry point
├── Config/
│   ├── Config.swift                    # Environment configuration
│   └── Info.plist
├── Models/
│   ├── User.swift                      # User model
│   ├── Task.swift                      # Task model
│   ├── Lesson.swift                    # Lesson model
│   ├── Question.swift                  # Question model
│   ├── TaskSession.swift               # Session model
│   ├── ProgressAnalytics.swift         # Analytics model
│   └── Level.swift                     # Level system model
├── ViewModels/
│   ├── AppViewModel.swift              # Main app state (Zustand equivalent)
│   ├── AuthViewModel.swift             # Authentication logic
│   ├── TaskViewModel.swift             # Task management
│   └── AnalyticsViewModel.swift        # Analytics logic
├── Views/
│   ├── App/
│   │   ├── AppRootView.swift          # Root navigation handler
│   │   ├── SplashView.swift           # Splash screen
│   │   └── OnboardingView.swift       # Onboarding flow
│   ├── Auth/
│   │   └── AuthView.swift             # Login/Register screen
│   ├── Tabs/
│   │   ├── TabBarView.swift           # Main tab bar
│   │   ├── HomeView.swift             # Dashboard/Home
│   │   ├── AnalyticsView.swift        # Analytics screen
│   │   └── ProfileView.swift          # Profile & settings
│   ├── Task/
│   │   ├── TaskDetailView.swift       # Task screen
│   │   ├── LessonView.swift           # Lesson viewer
│   │   ├── QuizView.swift             # Quiz questions
│   │   └── ResultView.swift           # Task result screen
│   └── Components/
│       ├── TaskCard.swift             # Task item card
│       ├── ProgressCard.swift         # Progress display
│       ├── WeeklyStreakChart.swift    # Streak visualization
│       ├── XPChart.swift              # XP chart
│       ├── SkillBreakdown.swift       # Radar chart
│       ├── PremiumButton.swift        # Custom button
│       ├── GradientBackground.swift   # Background component
│       └── LoadingView.swift          # Loading indicator
├── Services/
│   ├── SupabaseService.swift          # Supabase client & API
│   ├── AuthService.swift              # Authentication service
│   ├── TaskService.swift              # Task CRUD operations
│   ├── ProgressService.swift          # Progress tracking
│   └── AnalyticsService.swift         # Analytics data
├── Theme/
│   ├── Colors.swift                   # Color palette
│   ├── Typography.swift               # Text styles
│   ├── Spacing.swift                  # Spacing constants
│   └── ViewModifiers.swift            # Custom modifiers
├── Utils/
│   ├── Constants.swift                # App constants
│   ├── Extensions.swift               # Swift extensions
│   └── Helpers.swift                  # Helper functions
└── Resources/
    ├── Assets.xcassets                # Images & colors
    └── Localizable.strings            # Localization (optional)
```

---

## 4. Backend & Supabase Kurulumu

### 4.1 Supabase Project Oluşturma

```bash
1. https://supabase.com adresine git
2. Yeni proje oluştur
3. Project URL ve ANON_KEY değerlerini kaydet
```

### 4.2 Database Schema

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  level TEXT DEFAULT 'Beginner',
  xp INTEGER DEFAULT 0,
  total_xp INTEGER DEFAULT 0,
  streak INTEGER DEFAULT 0,
  last_activity_date DATE,
  completed_tasks_count INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  xp_reward INTEGER NOT NULL,
  duration INTEGER, -- in minutes
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  icon TEXT,
  color TEXT,
  content JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Task dependencies (for unlocking system)
CREATE TABLE IF NOT EXISTS task_dependencies (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  depends_on_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(task_id, depends_on_task_id)
);

-- Lessons table
CREATE TABLE IF NOT EXISTS lessons (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content JSONB NOT NULL,
  order_index INTEGER NOT NULL DEFAULT 0,
  duration INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Questions table
CREATE TABLE IF NOT EXISTS questions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL CHECK (question_type IN ('multiple_choice', 'code', 'true_false', 'fill_blank')),
  difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
  explanation TEXT,
  code_snippet TEXT,
  points INTEGER DEFAULT 10,
  order_index INTEGER NOT NULL DEFAULT 0,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Question options
CREATE TABLE IF NOT EXISTS question_options (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  order_index INTEGER NOT NULL DEFAULT 0,
  explanation TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User answers
CREATE TABLE IF NOT EXISTS user_answers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  selected_option_id UUID REFERENCES question_options(id) ON DELETE SET NULL,
  answer_text TEXT,
  is_correct BOOLEAN,
  points_earned INTEGER DEFAULT 0,
  time_spent INTEGER,
  attempt_number INTEGER DEFAULT 1,
  answered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User lesson progress
CREATE TABLE IF NOT EXISTS user_lesson_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  time_spent INTEGER DEFAULT 0,
  last_position INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- User task progress
CREATE TABLE IF NOT EXISTS user_task_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  is_unlocked BOOLEAN DEFAULT TRUE,
  started_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  score INTEGER,
  attempts INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, task_id)
);

-- XP History
CREATE TABLE IF NOT EXISTS xp_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  xp_gained INTEGER NOT NULL,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Skill breakdown
CREATE TABLE IF NOT EXISTS user_skills (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  skill_name TEXT NOT NULL,
  level INTEGER DEFAULT 0,
  xp INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, skill_name)
);

-- Row Level Security Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_task_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE xp_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_lesson_progress ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- User task progress policies
CREATE POLICY "Users can view their own progress"
  ON user_task_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own progress"
  ON user_task_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own progress"
  ON user_task_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- XP history policies
CREATE POLICY "Users can view their own XP history"
  ON xp_history FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own XP history"
  ON xp_history FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- User skills policies
CREATE POLICY "Users can view their own skills"
  ON user_skills FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own skills"
  ON user_skills FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own skills"
  ON user_skills FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- User answers policies
CREATE POLICY "Users can view their own answers"
  ON user_answers FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own answers"
  ON user_answers FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- User lesson progress policies
CREATE POLICY "Users can view their own lesson progress"
  ON user_lesson_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own lesson progress"
  ON user_lesson_progress FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own lesson progress"
  ON user_lesson_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Public read policies (tasks, lessons, questions can be read by anyone)
CREATE POLICY "Tasks are viewable by everyone"
  ON tasks FOR SELECT
  USING (true);

CREATE POLICY "Lessons are viewable by everyone"
  ON lessons FOR SELECT
  USING (true);

CREATE POLICY "Questions are viewable by everyone"
  ON questions FOR SELECT
  USING (true);

CREATE POLICY "Question options are viewable by everyone"
  ON question_options FOR SELECT
  USING (true);

CREATE POLICY "Task dependencies are viewable by everyone"
  ON task_dependencies FOR SELECT
  USING (true);
```

### 4.3 Seed Data (Sample Tasks)

```sql
-- Insert sample tasks
INSERT INTO tasks (title, category, description, xp_reward, duration, difficulty, icon, color) VALUES
('Binary Search Implementation', 'algorithmic-thinking', 'Master the binary search algorithm', 150, 15, 'medium', 'magnifyingglass', '#22D3EE'),
('Two Sum Problem', 'problem-solving', 'Solve the classic Two Sum problem', 100, 10, 'easy', 'number', '#10B981'),
('API Design Scenario', 'developer-scenario', 'Design a RESTful API for an e-commerce app', 200, 20, 'hard', 'network', '#A855F7'),
('Code Review: React Component', 'ai-review', 'Review and improve a React component', 120, 12, 'medium', 'doc.text.magnifyingglass', '#F59E0B');

-- Insert sample lessons for first task
INSERT INTO lessons (task_id, title, content, order_index, duration) VALUES
((SELECT id FROM tasks WHERE title = 'Binary Search Implementation'), 
 'Introduction to Binary Search', 
 '{"sections": [{"type": "heading", "content": "What is Binary Search?"}, {"type": "text", "content": "Binary search is an efficient algorithm for finding an item from a sorted list of items."}]}',
 0, 5);
```

---

## 5. Veri Modelleri

### 5.1 User Model

```swift
// Models/User.swift
import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var avatarUrl: String?
    var level: String
    var xp: Int
    var totalXp: Int
    var streak: Int
    var lastActivityDate: Date?
    var completedTasksCount: Int
    let joinedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case avatarUrl = "avatar_url"
        case level
        case xp
        case totalXp = "total_xp"
        case streak
        case lastActivityDate = "last_activity_date"
        case completedTasksCount = "completed_tasks_count"
        case joinedAt = "created_at"
    }
}
```

### 5.2 Task Model

```swift
// Models/Task.swift
import Foundation

enum TaskCategory: String, Codable, CaseIterable {
    case algorithmicThinking = "algorithmic-thinking"
    case problemSolving = "problem-solving"
    case developerScenario = "developer-scenario"
    case aiReview = "ai-review"
    
    var displayName: String {
        switch self {
        case .algorithmicThinking: return "Algorithmic Thinking"
        case .problemSolving: return "Problem Solving"
        case .developerScenario: return "Developer Scenario"
        case .aiReview: return "AI Review"
        }
    }
    
    var icon: String {
        switch self {
        case .algorithmicThinking: return "brain.head.profile"
        case .problemSolving: return "puzzlepiece.extension"
        case .developerScenario: return "laptopcomputer"
        case .aiReview: return "sparkles"
        }
    }
    
    var color: String {
        switch self {
        case .algorithmicThinking: return "#22D3EE"
        case .problemSolving: return "#10B981"
        case .developerScenario: return "#A855F7"
        case .aiReview: return "#F59E0B"
        }
    }
}

enum TaskDifficulty: String, Codable {
    case easy, medium, hard
}

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var category: TaskCategory
    var description: String
    var xpReward: Int
    var duration: Int // minutes
    var difficulty: TaskDifficulty
    var icon: String
    var color: String
    var content: [String: AnyCodable]?
    var isLocked: Bool = false
    var isCompleted: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id, title, category, description, duration, difficulty, icon, color, content
        case xpReward = "xp_reward"
    }
}

// Helper for dynamic JSON
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if let bool = value as? Bool {
            try container.encode(bool)
        }
    }
}
```

### 5.3 Lesson Model

```swift
// Models/Lesson.swift
import Foundation

enum LessonSectionType: String, Codable {
    case text, heading, code, list, example, tip, warning
}

struct LessonSection: Codable, Identifiable {
    var id: UUID = UUID()
    let type: LessonSectionType
    var content: String?
    var language: String?
    var code: String?
    var items: [String]?
    var title: String?
}

struct LessonContent: Codable {
    var sections: [LessonSection]
}

struct Lesson: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    var title: String
    var content: LessonContent
    var orderIndex: Int
    var duration: Int // minutes
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case title, content
        case orderIndex = "order_index"
        case duration
        case createdAt = "created_at"
    }
}
```

### 5.4 Question Model

```swift
// Models/Question.swift
import Foundation

enum QuestionType: String, Codable {
    case multipleChoice = "multiple_choice"
    case code
    case trueFalse = "true_false"
    case fillBlank = "fill_blank"
}

struct QuestionOption: Identifiable, Codable {
    let id: UUID
    let questionId: UUID
    var optionText: String
    var isCorrect: Bool
    var orderIndex: Int
    var explanation: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case optionText = "option_text"
        case isCorrect = "is_correct"
        case orderIndex = "order_index"
        case explanation
    }
}

struct Question: Identifiable, Codable {
    let id: UUID
    let taskId: UUID
    let lessonId: UUID?
    var questionText: String
    var questionType: QuestionType
    var difficulty: TaskDifficulty
    var explanation: String?
    var codeSnippet: String?
    var points: Int
    var orderIndex: Int
    var options: [QuestionOption]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "task_id"
        case lessonId = "lesson_id"
        case questionText = "question_text"
        case questionType = "question_type"
        case difficulty, explanation
        case codeSnippet = "code_snippet"
        case points
        case orderIndex = "order_index"
        case options
    }
}
```

### 5.5 Progress Models

```swift
// Models/ProgressAnalytics.swift
import Foundation

struct ProgressAnalytics: Codable {
    var weeklyStreak: [Bool]
    var xpHistory: [XPHistoryEntry]
    var skillBreakdown: SkillBreakdown
    var totalTimeSpent: Int // minutes
}

struct XPHistoryEntry: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let xp: Int
}

struct SkillBreakdown: Codable {
    var algorithmic: Int
    var problemSolving: Int
    var developerScenario: Int
    var aiReview: Int
}

struct UserTaskProgress: Codable {
    let id: UUID
    let userId: UUID
    let taskId: UUID
    var isCompleted: Bool
    var isUnlocked: Bool
    var startedAt: Date?
    var completedAt: Date?
    var score: Int?
    var attempts: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case taskId = "task_id"
        case isCompleted = "is_completed"
        case isUnlocked = "is_unlocked"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case score, attempts
    }
}

// Models/TaskSession.swift
struct TaskSession: Identifiable {
    let id = UUID()
    let taskId: UUID
    let startedAt: Date
    var completedAt: Date?
    var score: Int?
    var xpEarned: Int
}

// Models/Level.swift
struct Level: Identifiable {
    let id: Int
    let name: String
    let minXp: Int
    let maxXp: Int
}
```

---

## 6. State Management

### 6.1 AppViewModel (Ana State Manager - Zustand Equivalent)

```swift
// ViewModels/AppViewModel.swift
import Foundation
import Combine

@MainActor
class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var user: User?
    @Published var isAuthenticated: Bool = false
    @Published var isOnboarded: Bool = false
    @Published var isLoading: Bool = true
    
    @Published var tasks: [Task] = []
    @Published var currentTask: Task?
    @Published var completedTasksToday: [UUID] = []
    
    @Published var currentSession: TaskSession?
    @Published var analytics: ProgressAnalytics = ProgressAnalytics(
        weeklyStreak: Array(repeating: false, count: 7),
        xpHistory: [],
        skillBreakdown: SkillBreakdown(
            algorithmic: 0,
            problemSolving: 0,
            developerScenario: 0,
            aiReview: 0
        ),
        totalTimeSpent: 0
    )
    
    // MARK: - Services
    private let supabaseService = SupabaseService.shared
    private let authService = AuthService.shared
    private let taskService = TaskService.shared
    private let progressService = ProgressService.shared
    private let analyticsService = AnalyticsService.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        Task {
            await initialize()
        }
    }
    
    // MARK: - Actions
    func initialize() async {
        isLoading = true
        
        do {
            // Check auth session
            if let session = try await authService.getSession() {
                await loadUserData()
                await loadTasks()
                await loadAnalytics()
                isAuthenticated = true
            } else {
                isAuthenticated = false
            }
        } catch {
            print("Initialize error: \(error)")
            isAuthenticated = false
        }
        
        isLoading = false
    }
    
    func loadUserData() async {
        do {
            if let userId = try await authService.getCurrentUserId() {
                user = try await supabaseService.getUserProfile(userId: userId)
            }
        } catch {
            print("Load user data error: \(error)")
        }
    }
    
    func loadTasks() async {
        do {
            var allTasks = try await taskService.getAllTasks()
            
            // Load progress and set locked/completed status
            if let userId = user?.id {
                let progress = try await progressService.getUserTaskProgress(userId: userId)
                
                for i in 0..<allTasks.count {
                    if let taskProgress = progress.first(where: { $0.taskId == allTasks[i].id }) {
                        allTasks[i].isLocked = !taskProgress.isUnlocked
                        allTasks[i].isCompleted = taskProgress.isCompleted
                    }
                }
            }
            
            tasks = allTasks
        } catch {
            print("Load tasks error: \(error)")
        }
    }
    
    func loadAnalytics() async {
        guard let userId = user?.id else { return }
        
        do {
            analytics = try await analyticsService.getAnalytics(userId: userId)
        } catch {
            print("Load analytics error: \(error)")
        }
    }
    
    func setUser(_ newUser: User) {
        user = newUser
    }
    
    func updateXP(_ xpGained: Int) {
        guard var currentUser = user else { return }
        currentUser.xp += xpGained
        currentUser.totalXp += xpGained
        user = currentUser
        
        Task {
            do {
                try await progressService.updateUserXP(userId: currentUser.id, xpGained: xpGained)
            } catch {
                print("Update XP error: \(error)")
            }
        }
    }
    
    func incrementStreak() {
        guard var currentUser = user else { return }
        currentUser.streak += 1
        currentUser.lastActivityDate = Date()
        user = currentUser
        
        Task {
            do {
                try await progressService.incrementStreak(userId: currentUser.id)
            } catch {
                print("Increment streak error: \(error)")
            }
        }
    }
    
    func startTask(_ task: Task) {
        currentTask = task
        currentSession = TaskSession(
            taskId: task.id,
            startedAt: Date(),
            xpEarned: 0
        )
        
        Task {
            guard let userId = user?.id else { return }
            try? await progressService.markTaskStarted(userId: userId, taskId: task.id)
        }
    }
    
    func completeTask(xpEarned: Int, score: Int? = nil) async {
        guard let session = currentSession,
              let userId = user?.id else { return }
        
        do {
            // Update session
            var updatedSession = session
            updatedSession.completedAt = Date()
            updatedSession.xpEarned = xpEarned
            updatedSession.score = score
            currentSession = updatedSession
            
            // Update progress
            try await progressService.completeTask(
                userId: userId,
                taskId: session.taskId,
                score: score ?? 0
            )
            
            // Update XP
            updateXP(xpEarned)
            
            // Reload tasks
            await loadTasks()
            await loadAnalytics()
            
            // Add to completed today
            completedTasksToday.append(session.taskId)
            
        } catch {
            print("Complete task error: \(error)")
        }
    }
    
    func getCurrentLevel() -> (level: String, progress: Int, xpToNext: Int) {
        guard let user = user else {
            return ("Beginner", 0, 500)
        }
        
        let level = Constants.levels.first { user.xp >= $0.minXp && user.xp < $0.maxXp }
            ?? Constants.levels.last!
        
        let progress = Int((Double(user.xp - level.minXp) / Double(level.maxXp - level.minXp)) * 100)
        let xpToNext = level.maxXp - user.xp
        
        return (level.name, progress, xpToNext)
    }
    
    func resetSession() {
        currentSession = nil
        currentTask = nil
    }
    
    func signOut() async {
        do {
            try await authService.signOut()
            user = nil
            isAuthenticated = false
            tasks = []
            currentTask = nil
            currentSession = nil
        } catch {
            print("Sign out error: \(error)")
        }
    }
    
    func setOnboarded(_ value: Bool) {
        isOnboarded = value
        UserDefaults.standard.set(value, forKey: "isOnboarded")
    }
}
```

---

## 7. Navigation & Routing

### 7.1 App Root View

```swift
// Views/App/AppRootView.swift
import SwiftUI

struct AppRootView: View {
    @StateObject private var appVM = AppViewModel()
    @AppStorage("isOnboarded") private var isOnboarded: Bool = false
    
    var body: some View {
        Group {
            if appVM.isLoading {
                SplashView()
            } else if !isOnboarded {
                OnboardingView()
            } else if !appVM.isAuthenticated {
                AuthView()
            } else {
                TabBarView()
            }
        }
        .environmentObject(appVM)
    }
}
```

### 7.2 Tab Bar Navigation

```swift
// Views/Tabs/TabBarView.swift
import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(AppColors.primary)
    }
}
```

---

## 8. Tema & Tasarım Sistemi

### 8.1 Colors

```swift
// Theme/Colors.swift
import SwiftUI

struct AppColors {
    // Primary colors
    static let primary = Color(hex: "#22D3EE")
    static let primaryDark = Color(hex: "#06B6D4")
    static let primaryLight = Color(hex: "#67E8F9")
    
    // Background colors
    static let background = Color(hex: "#0B0F17")
    static let backgroundLight = Color(hex: "#111826")
    static let backgroundLighter = Color(hex: "#1E293B")
    
    // Surface colors
    static let surface = Color(hex: "#111826")
    static let surfaceLight = Color(hex: "#1E293B")
    static let surfaceLighter = Color(hex: "#334155")
    
    // Status colors
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error = Color(hex: "#EF4444")
    
    // Accent colors
    static let purple = Color(hex: "#A855F7")
    static let purpleLight = Color(hex: "#C084FC")
    
    // Text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "#94A3B8")
    static let textTertiary = Color(hex: "#64748B")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

### 8.2 Typography

```swift
// Theme/Typography.swift
import SwiftUI

struct AppTypography {
    // Font sizes
    static let xs: CGFloat = 12
    static let sm: CGFloat = 14
    static let base: CGFloat = 16
    static let lg: CGFloat = 18
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 30
    static let xxxxl: CGFloat = 36
    static let xxxxxl: CGFloat = 48
    
    // Font weights
    static let light = Font.Weight.light
    static let regular = Font.Weight.regular
    static let medium = Font.Weight.medium
    static let semibold = Font.Weight.semibold
    static let bold = Font.Weight.bold
    static let heavy = Font.Weight.heavy
    static let black = Font.Weight.black
}

extension Font {
    static func app(_ size: CGFloat, weight: Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .default)
    }
}
```

### 8.3 Spacing

```swift
// Theme/Spacing.swift
import SwiftUI

struct AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 40
    static let xxxl: CGFloat = 48
}
```

### 8.4 View Modifiers

```swift
// Theme/ViewModifiers.swift
import SwiftUI

// Card modifier
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Glow effect
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 1.5, x: 0, y: 0)
    }
}

// Premium button style
struct PremiumButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.app(16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
    
    func glowEffect(color: Color = AppColors.primary, radius: CGFloat = 10) -> some View {
        modifier(GlowModifier(color: color, radius: radius))
    }
    
    func premiumButtonStyle(color: Color = AppColors.primary) -> some View {
        buttonStyle(PremiumButtonStyle(color: color))
    }
}
```

---

## 9. Ekranlar (Views)

### 9.1 Splash Screen

```swift
// Views/App/SplashView.swift
import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#0F172A"),
                    Color(hex: "#1E1B4B"),
                    Color(hex: "#020617")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated orbs
            Circle()
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(AppColors.purple.opacity(0.1))
                .frame(width: 300, height: 300)
                .blur(radius: 50)
                .offset(x: 100, y: 200)
            
            // Logo and title
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primary, AppColors.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .glowEffect(color: AppColors.primary, radius: 20)
                
                Text("MindStack")
                    .font(.app(48, weight: .black))
                    .foregroundColor(.white)
                
                Text("Think like a developer")
                    .font(.app(16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
```

### 9.2 Onboarding View

```swift
// Views/App/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var currentPage = 0
    
    let pages: [(icon: String, title: String, description: String)] = [
        ("figure.mind.and.body", "Master Your Skills", "Level up your programming skills with daily challenges"),
        ("calendar.badge.clock", "Daily Training System", "Consistent practice builds expertise. Train every day."),
        ("chart.line.uptrend.xyaxis", "Track Your Progress", "Monitor your growth with detailed analytics"),
        ("star.fill", "Ready to Start?", "Begin your journey to becoming a better developer")
    ]
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            appVM.setOnboarded(true)
                        }
                        .font(.app(14, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                    }
                }
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(
                            icon: pages[index].icon,
                            title: pages[index].title,
                            description: pages[index].description
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Spacer()
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? AppColors.primary : AppColors.textTertiary)
                            .frame(width: 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Action button
                if currentPage == pages.count - 1 {
                    Button("Get Started") {
                        appVM.setOnboarded(true)
                    }
                    .premiumButtonStyle()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                } else {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .premiumButtonStyle()
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .glowEffect(color: AppColors.primary, radius: 20)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.app(32, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.app(16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding()
    }
}
```

### 9.3 Auth View

```swift
// Views/Auth/AuthView.swift
import SwiftUI

struct AuthView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 100)
                    
                    // Logo and title
                    VStack(spacing: 16) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .glowEffect(color: AppColors.primary, radius: 15)
                        
                        Text("MindStack")
                            .font(.app(40, weight: .black))
                            .foregroundColor(.white)
                        
                        Text("Think like a developer")
                            .font(.app(14, weight: .medium))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    
                    // Auth form
                    VStack(spacing: 20) {
                        // Toggle between login/register
                        HStack(spacing: 0) {
                            Button {
                                withAnimation(.spring()) {
                                    isLogin = true
                                }
                            } label: {
                                Text("Login")
                                    .font(.app(16, weight: .semibold))
                                    .foregroundColor(isLogin ? .white : AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        isLogin ? AppColors.primary.opacity(0.2) : Color.clear
                                    )
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                withAnimation(.spring()) {
                                    isLogin = false
                                }
                            } label: {
                                Text("Register")
                                    .font(.app(16, weight: .semibold))
                                    .foregroundColor(!isLogin ? .white : AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        !isLogin ? AppColors.primary.opacity(0.2) : Color.clear
                                    )
                                    .cornerRadius(8)
                            }
                        }
                        .background(AppColors.surface)
                        .cornerRadius(10)
                        
                        // Email field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.app(12, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                                .textCase(.uppercase)
                            
                            TextField("your@email.com", text: $email)
                                .textFieldStyle(PremiumTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        
                        // Password field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.app(12, weight: .semibold))
                                .foregroundColor(AppColors.textSecondary)
                                .textCase(.uppercase)
                            
                            SecureField("••••••••", text: $password)
                                .textFieldStyle(PremiumTextFieldStyle())
                                .textContentType(.password)
                        }
                        
                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(.app(12, weight: .medium))
                                .foregroundColor(AppColors.error)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Submit button
                        Button {
                            handleAuth()
                        } label: {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text(isLogin ? "Sign In" : "Create Account")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .premiumButtonStyle()
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                    .background(AppColors.surface.opacity(0.5))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func handleAuth() {
        errorMessage = nil
        isLoading = true
        
        Task {
            do {
                if isLogin {
                    try await AuthService.shared.signIn(email: email, password: password)
                } else {
                    try await AuthService.shared.signUp(email: email, password: password)
                }
                await appVM.initialize()
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// Premium text field style
struct PremiumTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.app(16, weight: .medium))
            .foregroundColor(.white)
            .padding()
            .background(AppColors.surfaceLight)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
            )
    }
}
```

### 9.4 Home View (Dashboard)

```swift
// Views/Tabs/HomeView.swift
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appVM: AppViewModel
    @State private var showTaskDetail = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        headerView
                        
                        // Progress card
                        progressCardView
                        
                        // Today's training
                        todaysTrainingSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                }
            }
            .navigationDestination(isPresented: $showTaskDetail) {
                if let task = selectedTask {
                    TaskDetailView(task: task)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            // Avatar
            AsyncImage(url: URL(string: appVM.user?.avatarUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(AppColors.primary)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(AppColors.primary.opacity(0.3), lineWidth: 2)
            )
            
            // Welcome text
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 6, height: 6)
                    
                    Text("WELCOME BACK")
                        .font(.app(10, weight: .bold))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(appVM.user?.name ?? "Developer")
                    .font(.app(18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // Streak badge
            streakBadge
        }
    }
    
    private var streakBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
                .font(.app(16))
            
            VStack(alignment: .leading, spacing: 0) {
                Text("STREAK")
                    .font(.app(8, weight: .bold))
                    .foregroundColor(.orange.opacity(0.7))
                
                Text("\(appVM.user?.streak ?? 0) Days")
                    .font(.app(14, weight: .black))
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.2), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var progressCardView: some View {
        let levelInfo = appVM.getCurrentLevel()
        return ProgressCard(
            level: levelInfo.level,
            xp: appVM.user?.xp ?? 0,
            progress: levelInfo.progress,
            xpToNext: levelInfo.xpToNext
        )
    }
    
    private var todaysTrainingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Training")
                        .font(.app(24, weight: .black))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(AppColors.primary)
                            .frame(width: 4, height: 4)
                        
                        Text("MASTER YOUR SKILLS")
                            .font(.app(10, weight: .bold))
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
                
                // Time badge
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.app(12))
                    Text("\(totalMinutes) min")
                        .font(.app(12, weight: .bold))
                }
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.surfaceLight)
                .cornerRadius(12)
            }
            
            // Task list
            ForEach(appVM.tasks) { task in
                TaskCard(task: task) {
                    selectedTask = task
                    showTaskDetail = true
                }
            }
        }
    }
    
    private var totalMinutes: Int {
        appVM.tasks.filter { !$0.isCompleted }.reduce(0) { $0 + $1.duration }
    }
}
```

### 9.5 Task Detail View

```swift
// Views/Task/TaskDetailView.swift
import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var appVM: AppViewModel
    @Environment(\.dismiss) private var dismiss
    let task: Task
    
    @State private var lessons: [Lesson] = []
    @State private var questions: [Question] = []
    @State private var isLoading = true
    @State private var showLesson = false
    @State private var showQuiz = false
    
    var body: some View {
        ZStack {
            GradientBackground()
            
            if isLoading {
                ProgressView()
                    .tint(AppColors.primary)
            } else {
               ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Task header
                        taskHeaderView
                        
                        // Start button
                        startButtonView
                        
                        // Lessons section
                        lessonsSectionView
                        
                        // Assessment section
                        assessmentSectionView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.app(16, weight: .semibold))
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .task {
            await loadTaskContent()
        }
        .sheet(isPresented: $showLesson) {
            if let firstLesson = lessons.first {
                LessonView(lesson: firstLesson, onComplete: {
                    showLesson = false
                    showQuiz = true
                })
            }
        }
        .sheet(isPresented: $showQuiz) {
            QuizView(questions: questions, task: task)
        }
    }
    
    private var taskHeaderView: some View {
        VStack(spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color(hex: task.color).opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: task.icon)
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: task.color))
            }
            .glowEffect(color: Color(hex: task.color), radius: 15)
            
            // Title and category
            VStack(spacing: 8) {
                Text(task.title)
                    .font(.app(28, weight: .black))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(task.category.displayName)
                    .font(.app(14, weight: .semibold))
                    .foregroundColor(Color(hex: task.color))
                    .textCase(.uppercase)
            }
            
            // Meta info
            HStack(spacing: 20) {
                metaItem(icon: "clock.fill", text: "\(task.duration) min")
                metaItem(icon: "star.fill", text: "+\(task.xpReward) XP")
                metaItem(icon: "chart.bar.fill", text: task.difficulty.rawValue.capitalized)
            }
        }
        .padding(.vertical, 24)
    }
    
    private func metaItem(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.app(12))
            Text(text)
                .font(.app(14, weight: .semibold))
        }
        .foregroundColor(AppColors.textSecondary)
    }
    
    private var startButtonView: some View {
        Button {
            appVM.startTask(task)
            showLesson = true
        } label: {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Learning")
                    .font(.app(18, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [Color(hex: task.color), Color(hex: task.color).opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
            .glowEffect(color: Color(hex: task.color), radius: 10)
        }
        .disabled(task.isLocked)
        .opacity(task.isLocked ? 0.5 : 1.0)
    }
    
    private var lessonsSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Course Content")
                .font(.app(20, weight: .bold))
                .foregroundColor(.white)
            
            ForEach(Array(lessons.enumerated()), id: \.element.id) { index, lesson in
                LessonItemView(lesson: lesson, index: index + 1)
            }
        }
    }
    
    private var assessmentSectionView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Assessment")
                .font(.app(20, weight: .bold))
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(AppColors.primary)
                Text("\(questions.count) Questions")
                    .font(.app(14, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(questions.reduce(0) { $0 + $1.points }) Points")
                    .font(.app(14, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(12)
        }
    }
    
    private func loadTaskContent() async {
        defer { isLoading = false }
        
        do {
            async let lessonsTask = TaskService.shared.getLessons(taskId: task.id)
            async let questionsTask = TaskService.shared.getQuestions(taskId: task.id)
            
            lessons = try await lessonsTask
            questions = try await questionsTask
        } catch {
            print("Load task content error: \(error)")
        }
    }
}

struct LessonItemView: View {
    let lesson: Lesson
    let index: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Number badge
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                Text("\(index)")
                    .font(.app(14, weight: .bold))
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.app(16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(lesson.duration) min")
                    .font(.app(12, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.app(14))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}
```

---

## 10. UI Bileşenleri

### 10.1 TaskCard

```swift
// Views/Components/TaskCard.swift
import SwiftUI

struct TaskCard: View {
    let task: Task
    let onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: task.color).opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: task.icon)
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: task.color))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(task.title)
                        .font(.app(16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(task.duration) min", systemImage: "clock")
                        Label("+\(task.xpReward) XP", systemImage: "star.fill")
                    }
                    .font(.app(12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Status
                if task.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.app(24))
                        .foregroundColor(AppColors.success)
                } else if task.isLocked {
                    Image(systemName: "lock.fill")
                        .font(.app(20))
                        .foregroundColor(AppColors.textTertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.app(16))
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(hex: task.color).opacity(0.2), lineWidth: 1)
            )
        }
        .disabled(task.isLocked)
        .opacity(task.isLocked ? 0.6 : 1.0)
    }
}
```

### 10.2 ProgressCard

```swift
// Views/Components/ProgressCard.swift
import SwiftUI

struct ProgressCard: View {
    let level: String
    let xp: Int
    let progress: Int
    let xpToNext: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Level info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Level")
                        .font(.app(12, weight: .semibold))
                        .foregroundColor(AppColors.textSecondary)
                        .textCase(.uppercase)
                    
                    Text(level)
                        .font(.app(24, weight: .black))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(xp) XP")
                        .font(.app(20, weight: .black))
                        .foregroundColor(AppColors.primary)
                    
                    Text("\(xpToNext) to next")
                        .font(.app(12, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.surfaceLight)
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(progress) / 100, height: 12)
                        .glowEffect(color: AppColors.primary, radius: 5)
                }
            }
            .frame(height: 12)
            
            // Progress percentage
            HStack {
                Text("\(progress)% Complete")
                    .font(.app(12, weight: .semibold))
                    .foregroundColor(AppColors.textSecondary)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    AppColors.surface,
                    AppColors.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )    }
}
```

### 10.3 GradientBackground

```swift
// Views/Components/GradientBackground.swift
import SwiftUI

struct GradientBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "#0F172A"),
                    Color(hex: "#1E1B4B"),
                    Color(hex: "#020617")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated orbs
            Circle()
                .fill(AppColors.primary.opacity(0.05))
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .offset(x: -100, y: -150)
            
            Circle()
                .fill(AppColors.purple.opacity(0.05))
                .frame(width: 350, height: 350)
                .blur(radius: 50)
                .offset(x: 150, y: 200)
        }
    }
}
```

---

## 11. Servisler

### 11.1 SupabaseService

```swift
// Services/SupabaseService.swift
import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        guard let url = URL(string: Config.supabaseURL),
              let key = Config.supabaseAnonKey else {
            fatalError("Supabase configuration missing")
        }
        
        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
    
    // User Profile
    func getUserProfile(userId: UUID) async throws -> User {
        let response: User = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
        
        return response
    }
    
    func updateUserProfile(userId: UUID, updates: [String: Any]) async throws {
        try await client
            .from("profiles")
            .update(updates)
            .eq("id", value: userId.uuidString)
            .execute()
    }
}
```

### 11.2 AuthService

```swift
// Services/AuthService.swift
import Foundation
import Supabase

class AuthService {
    static let shared = AuthService()
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    func signUp(email: String, password: String) async throws {
        _ = try await supabase.auth.signUp(email: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await supabase.auth.signIn(email: email, password: password)
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getSession() async throws -> Session? {
        return try await supabase.auth.session
    }
    
    func getCurrentUserId() async throws -> UUID? {
        guard let session = try await getSession() else { return nil }
        return UUID(uuidString: session.user.id.uuidString)
    }
}
```

### 11.3 TaskService

```swift
// Services/TaskService.swift
import Foundation

class TaskService {
    static let shared = TaskService()
    private let supabase = SupabaseService.shared.client
    
    private init() {}
    
    func getAllTasks() async throws -> [Task] {
        let response: [Task] = try await supabase
            .from("tasks")
            .select()
            .order("created_at")
            .execute()
            .value
        
        return response
    }
    
    func getLessons(taskId: UUID) async throws -> [Lesson] {
        let response: [Lesson] = try await supabase
            .from("lessons")
            .select()
            .eq("task_id", value: taskId.uuidString)
            .order("order_index")
            .execute()
            .value
        
        return response
    }
    
    func getQuestions(taskId: UUID) async throws -> [Question] {
        let response: [Question] = try await supabase
            .from("questions")
            .select("*, options:question_options(*)")
            .eq("task_id", value: taskId.uuidString)
            .order("order_index")
            .execute()
            .value
        
        return response
    }
}
```

---

## 12. Animasyonlar

```swift
// Utils/Animations.swift
import SwiftUI

extension Animation {
    static let springy = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

// Fade in animation
struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.smooth) {
                    opacity = 1
                }
            }
    }
}

// Scale animation
struct ScaleInModifier: ViewModifier {
    @State private var scale: CGFloat = 0.8
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.springy) {
                    scale = 1.0
                }
            }
    }
}

extension View {
    func fadeIn() -> some View {
        modifier(FadeInModifier())
    }
    
    func scaleIn() -> some View {
        modifier(ScaleInModifier())
    }
}
```

---

## 13. Dependencies & SPM

### Package.swift ya da Xcode SPM

```swift
// Xcode: File > Add Package Dependencies

dependencies: [
    // Supabase Swift SDK
    .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
]
```

---

## 14. Kurulum Adımları

### 14.1 Xcode Project Oluşturma

```bash
1. Xcode'u aç
2. Create New Project > iOS > App
3. Product Name: MindStack
4. Interface: SwiftUI
5. Language: Swift
6. Minimum iOS: 16.0
```

### 14.2 Supabase Dependency Ekleme

```bash
1. File > Add Package Dependencies
2. URL: https://github.com/supabase/supabase-swift
3. Version: "Up to Next Major" 2.0.0
4. Add to Target: MindStack
```

### 14.3 Config Dosyası

```swift
// Config/Config.swift
import Foundation

enum Config {
    static let supabaseURL = "https://your-project.supabase.co"
    static let supabaseAnonKey = "your-anon-key"
}

// VEYA .env kullanımı için:
// Info.plist'e ekle:
// SUPABASE_URL: $(SUPABASE_URL)
// SUPABASE_ANON_KEY: $(SUPABASE_ANON_KEY)

extension Config {
    static var supabaseURL: String {
        Bundle.main.infoDictionary?["SUPABASE_URL"] as? String ?? ""
    }
    
    static var supabaseAnonKey: String {
        Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String ?? ""
    }
}
```

### 14.4 Constants

```swift
// Utils/Constants.swift
import Foundation

enum Constants {
    static let appName = "MindStack"
    static let appTagline = "Think like a developer"
    
    static let levels = [
        Level(id: 1, name: "Beginner", minXp: 0, maxXp: 500),
        Level(id: 2, name: "Junior Thinker", minXp: 500, maxXp: 1500),
        Level(id: 3, name: "Mid-Level Solver", minXp: 1500, maxXp: 3000),
        Level(id: 4, name: "Senior Problem Solver", minXp: 3000, maxXp: 5000),
        Level(id: 5, name: "Master Developer", minXp: 5000, maxXp: Int.max)
    ]
}
```

---

## 15. Implementation Checklist

### ✅ **Temel Yapı**
- [ ] Xcode projesi oluştur
- [ ] Proje yapısını kur (folders)
- [ ] Supabase SDK ekle
- [ ] Config dosyasını ayarla

### ✅ **Models**
- [ ] User model
- [ ] Task model
- [ ] Lesson model
- [ ] Question model
- [ ] Progress models

### ✅ **Services**
- [ ] SupabaseService
- [ ] AuthService
- [ ] TaskService
- [ ] ProgressService
- [ ] AnalyticsService

### ✅ **ViewModels**
- [ ] AppViewModel (ana state manager)
- [ ] AuthViewModel
- [ ] TaskViewModel
- [ ] AnalyticsViewModel

### ✅ **Theme**
- [ ] Colors
- [ ] Typography
- [ ] Spacing
- [ ] View Modifiers

### ✅ **Views - App Flow**
- [ ] AppRootView
- [ ] SplashView
- [ ] OnboardingView
- [ ] AuthView

### ✅ **Views - Main Tabs**
- [ ] TabBarView
- [ ] HomeView
- [ ] AnalyticsView
- [ ] ProfileView

### ✅ **Views - Task Flow**
- [ ] TaskDetailView
- [ ] LessonView
- [ ] QuizView
- [ ] ResultView

### ✅ ** UI Components**
- [ ] TaskCard
- [ ] ProgressCard
- [ ] WeeklyStreakChart
- [ ] XPChart
- [ ] SkillBreakdown
- [ ] GradientBackground
- [ ] LoadingView

### ✅ **Backend**
- [ ] Supabase project oluştur
- [ ] Database schema çalıştır
- [ ] RLS policies aktifleştir
- [ ] Seed data ekle (optional)

### ✅ **Testing**
- [ ] Auth flow test et
- [ ] Task flow test et
- [ ] Progress tracking test et
- [ ] Analytics test et

---

## 16. Önemli Notlar

### Performance
- **LazyVStack/LazyHStack** kullan (büyük listeler için)
- **@MainActor** ile UI güncellemelerini garanti et
- **Task** ile async operations yönet

### Security
- **Environment variables** ile credentials yönet
- **Keychain** ile token storage
- **RLS Policies** ile data security

### Best Practices
- **MVVM** pattern kullan
- **Dependency Injection** ile servisler
- **Protocol-Oriented Programming**
- **SwiftUI Lifecycle** kullan

### UI/UX
- **Dark mode** öncelikli
- **Smooth animations** (spring, easeInOut)
- **Haptic feedback** ekle (önemli aksiyonlarda)
- **Loading states** göster
- **Error handling** ile user-friendly mesajlar

---

## 17. Örnek Implementation Flow

```swift
// 1. MindStackApp.swift
@main
struct MindStackApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}

// 2. AppRootView.swift ile flow kontrol
// 3. AppViewModel ile state management
// 4. Navigation Stack ile screen transitions
// 5. Services ile backend operations
```

---

Bu yönerge, MindStack uygulamasının Swift/SwiftUI ile tamamen yeniden yazılması için gereken tüm bilgileri içermektedir. Bir AI agent bu belgeyi okuyarak:

1. **Proje yapısını** kurabilir
2. **Tüm modelleri** oluşturabilir
3. **Service layer**'ı implement edebilir
4. **UI bileşenlerini** geliştirebilir
5. **State management** yapabilir
6. **Backend entegrasyonu** yapabilir
7. **Complete app flow** oluşturabilir

Her bölüm detaylı kod örnekleri ve açıklamalarla hazırlanmıştır. 🚀
