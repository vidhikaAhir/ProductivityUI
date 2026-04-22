import Foundation
import UserNotifications

protocol NotificationServiceProtocol {
    func fetchNotifications() -> [AppNotificationItem]
    func syncReminderNotifications(from tasks: [TaskItem])
    func markAsViewed(id: UUID)
    func markAllAsViewed()
}

final class InMemoryNotificationService: NotificationServiceProtocol {
    private var notifications: [AppNotificationItem]
    private var scheduledTaskIDs: Set<UUID>

    init() {
        let now = Date()
        let oldDate = Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now
        self.notifications = [
            AppNotificationItem(title: "Welcome", message: "Your productivity workspace is ready.", createdAt: now, isViewed: false),
            AppNotificationItem(title: "Yesterday Summary", message: "You completed 3 of 5 tasks.", createdAt: oldDate, isViewed: true)
        ]
        self.scheduledTaskIDs = Set(notifications.compactMap(\.relatedTaskID))
        requestAuthorization()
    }

    func fetchNotifications() -> [AppNotificationItem] {
        notifications.sorted(by: { $0.createdAt > $1.createdAt })
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
        }
    }

    func markAsViewed(id: UUID) {
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isViewed = true
    }

    func markAllAsViewed() {
        for index in notifications.indices {
            notifications[index].isViewed = true
        }
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
}
