import Foundation

struct TaskItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var dueDate: Date?
    var hasReminder: Bool
    var priority: TaskPriority
    var isCompleted: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        dueDate: Date? = nil,
        hasReminder: Bool = false,
        priority: TaskPriority = .medium,
        isCompleted: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.dueDate = dueDate
        self.hasReminder = hasReminder
        self.priority = priority
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }

    init(from row: TaskModel) {
        self.id = UUID(uuidString: row.id) ?? UUID()
        self.title = row.title
        self.detail = row.description ?? ""
        self.dueDate = row.dueDateValue
        self.hasReminder = row.reminder
        self.priority = row.priorityValue
        self.isCompleted = row.is_completed
        self.createdAt = SupabaseDateTransform.parseDate(row.created_at) ?? Date()
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case detail
        case dueDate = "due_date"
        case hasReminder = "has_reminder"
        case priority
        case isCompleted = "is_completed"
        case createdAt = "created_at"
    }
}

enum TaskPriority: String, CaseIterable, Identifiable, Codable {
    case low
    case medium
    case high

    var id: String { rawValue }
}
