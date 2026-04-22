import Foundation

struct HabitLog: Identifiable, Equatable, Codable {
    let id: UUID
    let habitId: UUID
    let completedAt: Date

    init(id: UUID = UUID(), habitId: UUID, completedAt: Date = Date()) {
        self.id = id
        self.habitId = habitId
        self.completedAt = completedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case habitId = "habit_id"
        case completedAt = "completed_at"
    }
}
