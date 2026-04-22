import Foundation

protocol TaskServiceProtocol {
    func fetchTasks() async throws -> [TaskItem]
    func addTask(_ task: TaskItem) async throws
    func updateTask(_ task: TaskItem) async throws
    func deleteTask(id: UUID) async throws
}

final class SupabaseTaskService: TaskServiceProtocol {
    init() {}

    func fetchTasks() async throws -> [TaskItem] {
        let userID = try await UserRowData.shared.activeUserID()
        let rows = try await TaskDB.shared.fetchTasks(user_id: userID)
        return rows.map(TaskItem.init(from:))
    }

    func addTask(_ task: TaskItem) async throws {
        let userID = try await UserRowData.shared.activeUserID()
        try await TaskDB.shared.addTask(
            id: task.id.uuidString,
            user_id: userID,
            title: task.title,
            description: task.detail.isEmpty ? "" : task.detail,
            due_date: SupabaseDateTransform.dateString(from: task.dueDate),
            due_time: SupabaseDateTransform.timeString(from: task.dueDate),
            reminder: task.hasReminder,
            priority: task.priority.rawValue,
            is_completed: task.isCompleted
        )
    }

    func updateTask(_ task: TaskItem) async throws {
        try await TaskDB.shared.updateTask(
            title: task.title,
            description: task.detail,
            priority: task.priority.rawValue,
            is_completed: task.isCompleted,
            due_date: SupabaseDateTransform.dateString(from: task.dueDate),
            due_time: SupabaseDateTransform.timeString(from: task.dueDate),
            reminder: task.hasReminder,
            id: task.id.uuidString
        )
    }

    func deleteTask(id: UUID) async throws {
        try await TaskDB.shared.deleteTask(id: id.uuidString)
    }
}
