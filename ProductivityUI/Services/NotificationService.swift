import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func fetchNotifications() -> [AppNotificationItem]
    func recordNotification(_ notification: AppNotificationItem)
    func syncReminderNotifications(from tasks: [TaskItem])
    func markAsViewed(id: UUID)
    func markAllAsViewed()
}

final class InMemoryNotificationService: NotificationServiceProtocol {
    static let shared = InMemoryNotificationService()

    private var notifications: [AppNotificationItem]
    private var scheduledTaskIDs: Set<UUID>
    private let storageKey = "notification_service_state_v1"

    init() {
        if let state = Self.loadState(from: storageKey) {
            self.notifications = state.notifications
            self.scheduledTaskIDs = Set(state.scheduledTaskIDs)
        } else {
            let now = Date()
            let oldDate = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
            self.notifications = [
                AppNotificationItem(title: "Welcome", message: "Your productivity workspace is ready.", createdAt: now, isViewed: false),
                AppNotificationItem(title: "Yesterday Summary", message: "You completed 3 of 5 tasks.", createdAt: oldDate, isViewed: true)
            ]
            self.scheduledTaskIDs = Set(notifications.compactMap(\.relatedTaskID))
            saveState()
        }
        requestAuthorization()
    }

    func fetchNotifications() -> [AppNotificationItem] {
        notifications.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func recordNotification(_ notification: AppNotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = notification
        } else {
            notifications.append(notification)
        }
        saveState()
    }

    func syncReminderNotifications(from tasks: [TaskItem]) {
        let reminderTasks = tasks.compactMap { task -> (task: TaskItem, fireDate: Date)? in
            guard task.hasReminder, task.isCompleted == false, let dueDate = task.dueDate else { return nil }
            let now = Date()
            let oneHourBefore = dueDate.addingTimeInterval(-3600)
            let fireDate: Date?
            if oneHourBefore > now {
                fireDate = oneHourBefore
            } else if dueDate > now {
                fireDate = now.addingTimeInterval(1)
            } else {
                fireDate = nil
            }
            guard let fireDate else { return nil }
            return (task, fireDate)
        }

        let desiredTaskIDs = Set(reminderTasks.map(\.task.id))
        let staleTaskIDs = scheduledTaskIDs.subtracting(desiredTaskIDs)

        if staleTaskIDs.isEmpty == false {
            removeNotifications(forTaskIDs: staleTaskIDs)
        }

        for item in reminderTasks {
            let notification = AppNotificationItem(
                id: item.task.id,
                relatedTaskID: item.task.id,
                title: "Reminder",
                message: "Only one hour left. Hurry! Complete: \(item.task.title)",
                createdAt: item.fireDate,
                isViewed: false
            )
            upsert(notification)
            scheduleLocalNotification(for: notification)
        }

        scheduledTaskIDs = desiredTaskIDs
        saveState()
    }

    func markAsViewed(id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isViewed = true
        saveState()
    }

    func markAllAsViewed() {
        for index in notifications.indices {
            notifications[index].isViewed = true
        }
        saveState()
    }

    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }

    private func scheduleLocalNotification(for notification: AppNotificationItem) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default

        let secondsUntilFire = max(notification.createdAt.timeIntervalSinceNow, 1)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsUntilFire, repeats: false)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.id.uuidString])
        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func upsert(_ notification: AppNotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            let isViewed = notifications[index].isViewed
            notifications[index] = AppNotificationItem(
                id: notification.id,
                relatedTaskID: notification.relatedTaskID,
                title: notification.title,
                message: notification.message,
                createdAt: notification.createdAt,
                isViewed: isViewed
            )
        } else {
            notifications.append(notification)
        }
    }

    private func removeNotifications(forTaskIDs taskIDs: Set<UUID>) {
        scheduledTaskIDs.subtract(taskIDs)
        let identifiers = taskIDs.map(\.uuidString)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func saveState() {
        let state = PersistedState(
            notifications: notifications,
            scheduledTaskIDs: Array(scheduledTaskIDs)
        )
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func loadState(from key: String) -> PersistedState? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(PersistedState.self, from: data)
    }

    private struct PersistedState: Codable {
        let notifications: [AppNotificationItem]
        let scheduledTaskIDs: [UUID]
    }
}
