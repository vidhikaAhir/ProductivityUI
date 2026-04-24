import Foundation
import Combine

@MainActor
final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published private(set) var isLoading = false
    @Published var selectedFilter: Filter = .inProgress

    enum Filter: String, CaseIterable, Identifiable {
        case inProgress = "In Progress"
        case completed = "Completed"
        var id: String { rawValue }
    }

    private let taskService: TaskServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let onNotificationChanged: (() -> Void)?

    init(
        taskService: TaskServiceProtocol,
        notificationService: NotificationServiceProtocol,
        onNotificationChanged: (() -> Void)? = nil
    ) {
        self.taskService = taskService
        self.notificationService = notificationService
        self.onNotificationChanged = onNotificationChanged
        Task { await loadData() }
    }

    var filteredTasks: [TaskItem] {
        switch selectedFilter {
        case .inProgress:
            return tasks.filter { !$0.isCompleted }
        case .completed:
            return tasks.filter { $0.isCompleted }
        }
    }

    var completedTasks: [TaskItem] {
        tasks.filter(\.isCompleted)
    }

    func refresh() {
        Task { await loadData() }
    }
    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            tasks = try await taskService.fetchTasks()
            notificationService.syncReminderNotifications(from: tasks)
            onNotificationChanged?()
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    func addTask(title: String, detail: String, dueDate: Date?, hasReminder: Bool, priority: TaskPriority) {
        let task = TaskItem(title: title, detail: detail, dueDate: dueDate, hasReminder: hasReminder, priority: priority)
        let nextTasks = tasks + [task]
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await taskService.addTask(task)
                notificationService.syncReminderNotifications(from: nextTasks)
                await loadData()
            } catch {
                print("Failed to add task: \(error)")
            }
        }
    }

    func updateTask(_ task: TaskItem) {
        let nextTasks = tasks.map { $0.id == task.id ? task : $0 }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await taskService.updateTask(task)
                notificationService.syncReminderNotifications(from: nextTasks)
                await loadData()
            } catch {
                print("Failed to update task: \(error)")
            }
        }
    }

    func deleteTask(_ task: TaskItem) {
        let nextTasks = tasks.filter { $0.id != task.id }
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await taskService.deleteTask(id: task.id)
                notificationService.syncReminderNotifications(from: nextTasks)
                await loadData()
            } catch {
                print("Failed to delete task: \(error)")
            }
        }
    }

    func toggleCompletion(_ task: TaskItem) {
        var updated = task
        updated.isCompleted.toggle()
        updateTask(updated)
    }
}
