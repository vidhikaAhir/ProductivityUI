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
        guard notifications.contains(where: { $0.id == notification.id }) == false else { return }
        notifications.append(notification)
        saveState()
    }

    func syncReminderNotifications(from tasks: [TaskItem]) {
        for task in tasks where task.hasReminder {
            guard scheduledTaskIDs.contains(task.id) == false else { continue }

            let notification = AppNotificationItem(
                relatedTaskID: task.id,
                title: "Task Reminder",
                message: task.title,
                createdAt: task.dueDate ?? Date(),
                isViewed: false
            )
            notifications.append(notification)
            scheduledTaskIDs.insert(task.id)
            scheduleLocalNotification(for: notification)
            saveState()
        }
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
        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
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
