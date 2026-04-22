import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error {
                print("Notification permission error: \(error)")
                return
            }
            print("Notification permission granted: \(granted)")
        }
    }

    func scheduleHabitReminder(
        title: String,
        expTime: Date,
        notificationService: NotificationServiceProtocol,
        completion: (() -> Void)? = nil
    ) {
        let calendar = Calendar.current
        let now = Date()

        let expComponents = calendar.dateComponents([.hour, .minute], from: expTime)
        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: now)
        triggerComponents.hour = expComponents.hour
        triggerComponents.minute = expComponents.minute

        guard let targetDate = calendar.date(from: triggerComponents) else {
            return
        }

        let fireDate = targetDate.addingTimeInterval(-3600)
        guard fireDate > now else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Only one hour left. Hurry! Complete: \(title)"
        content.sound = .default

        let fireComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
        let notification = AppNotificationItem(
            title: content.title,
            message: content.body,
            createdAt: fireDate,
            isViewed: false
        )

        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("Failed to schedule habit reminder: \(error)")
                return
            }
            notificationService.recordNotification(notification)
            completion?()
        }
    }
}
