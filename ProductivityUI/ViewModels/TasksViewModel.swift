import Foundation
import Combine

final class TasksViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var selectedFilter: Filter = .inProgress

    enum Filter: String, CaseIterable, Identifiable {
        case inProgress = "In Progress"
        case completed = "Completed"
        var id: String { rawValue }
    }

    private let taskService: TaskServiceProtocol

    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
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
        do {
            tasks = try await taskService.fetchTasks()
        } catch {
            print("Failed to fetch tasks: \(error)")
        }
    }

    func addTask(title: String, detail: String, dueDate: Date?, hasReminder: Bool, priority: TaskPriority) {
        let task = TaskItem(title: title, detail: detail, dueDate: dueDate, hasReminder: hasReminder, priority: priority)
        Task {
            do {
                try await taskService.addTask(task)
                await loadData()
            } catch {
                print("Failed to add task: \(error)")
            }
        }
    }

    func updateTask(_ task: TaskItem) {
        Task {
            do {
                try await taskService.updateTask(task)
                await loadData()
            } catch {
                print("Failed to update task: \(error)")
            }
        }
    }

    func deleteTask(_ task: TaskItem) {
        Task {
            do {
                try await taskService.deleteTask(id: task.id)
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
