import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published private(set) var tasks: [TaskItem] = []
    @Published private(set) var notes: [NoteItem] = []
    @Published private(set) var habits: [HabitItem] = []
    @Published private(set) var notifications: [AppNotificationItem] = []
    @Published private(set) var isLoading = false

    private let taskService: TaskServiceProtocol
    private let noteService: NoteServiceProtocol
    private let habitService: HabitServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let calendar = Calendar.current

    init(
        taskService: TaskServiceProtocol,
        noteService: NoteServiceProtocol,
        habitService: HabitServiceProtocol,
        notificationService: NotificationServiceProtocol
    ) {
        self.taskService = taskService
        self.noteService = noteService
        self.habitService = habitService
        self.notificationService = notificationService
        Task { await loadData() }
    }

    var currentMonthTitle: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }

    var itemsForSelectedDate: [CalendarFeedItem] {
        let dayTasks = tasks.filter {
            guard let dueDate = $0.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }.map {
            CalendarFeedItem(id: $0.id, date: $0.dueDate ?? selectedDate, title: $0.title, subtitle: $0.priority.rawValue.capitalized, type: .task($0))
        }

        let reminders = tasks.filter {
            guard let dueDate = $0.dueDate else { return false }
            return $0.hasReminder && calendar.isDate(dueDate, inSameDayAs: selectedDate)
        }.map {
            CalendarFeedItem(id: UUID(), date: $0.dueDate ?? selectedDate, title: "Reminder: \($0.title)", subtitle: "Notification", type: .reminder($0))
        }

        let dayNotes = notes.prefix(2).map {
            CalendarFeedItem(id: $0.id, date: $0.updatedAt, title: $0.title, subtitle: "Note", type: .note($0))
        }

        let dayHabits = habits.filter { $0.isCompleted(on: selectedDate) }.map {
            CalendarFeedItem(id: $0.id, date: selectedDate, title: $0.title, subtitle: "Habit completed", type: .habit($0))
        }

        return (dayTasks + reminders + dayNotes + dayHabits).sorted(by: { $0.date < $1.date })
    }

    var unviewedCount: Int {
        notifications.filter { !$0.isViewed }.count
    }

    var unviewedNotifications: [AppNotificationItem] {
        notifications.filter { !$0.isViewed }
    }

    var viewedNotifications: [AppNotificationItem] {
        notifications.filter(\.isViewed)
    }

    func refresh() {
        Task { await loadData() }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let fetchedTasks = taskService.fetchTasks()
            async let fetchedNotes = noteService.fetchNotes()
            async let fetchedHabits = habitService.fetchHabits()

            tasks = try await fetchedTasks
            notes = try await fetchedNotes
            habits = try await fetchedHabits
            notificationService.syncReminderNotifications(from: tasks)
            notifications = notificationService.fetchNotifications()
        } catch {
            print("Failed to fetch calendar data: \(error)")
        }
    }

    func markNotificationAsViewed(_ item: AppNotificationItem) {
        notificationService.markAsViewed(id: item.id)
        notifications = notificationService.fetchNotifications()
    }

    func markAllNotificationsAsViewed() {
        notificationService.markAllAsViewed()
        notifications = notificationService.fetchNotifications()
    }

    func monthDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end.addingTimeInterval(-1)) else {
            return []
        }

        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        return calendar.generateDates(inside: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
    }

    func hasAnyItem(on date: Date) -> Bool {
        taskDots(on: date).isEmpty == false || habitDots(on: date).isEmpty == false || noteDots(on: date).isEmpty == false
    }

    func taskDots(on date: Date) -> [CalendarFeedType] {
        tasks.compactMap { task in
            guard let due = task.dueDate, calendar.isDate(due, inSameDayAs: date) else { return nil }
            return .task(task)
        }
    }

    func noteDots(on date: Date) -> [CalendarFeedType] {
        notes.filter { calendar.isDate($0.updatedAt, inSameDayAs: date) }.map { .note($0) }
    }

    func habitDots(on date: Date) -> [CalendarFeedType] {
        habits.filter { $0.isCompleted(on: date) }.map { .habit($0) }
    }
}

private extension Calendar {
    func generateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)

        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            if date < interval.end {
                dates.append(date)
            } else {
                stop = true
            }
        }
        return dates
    }
}
