import Foundation
import Combine

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published private(set) var habits: [HabitItem] = []
    @Published private(set) var isLoading = false

    private let habitService: HabitServiceProtocol
    private let notificationService: NotificationServiceProtocol
    private let notificationManager: NotificationManager
    private let onNotificationChanged: (() -> Void)?
    private let calendar = Calendar.current

    init(
        habitService: HabitServiceProtocol,
        notificationService: NotificationServiceProtocol,
        notificationManager: NotificationManager = .shared,
        onNotificationChanged: (() -> Void)? = nil
    ) {
        self.habitService = habitService
        self.notificationService = notificationService
        self.notificationManager = notificationManager
        self.onNotificationChanged = onNotificationChanged
        Task { await loadData() }
    }

    func refresh() {
        Task { await loadData() }
    }

    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            habits = try await habitService.fetchHabits()
        } catch {
            print("Failed to fetch habits: \(error)")
        }
    }

    func addHabit(title: String, detail: String, expTime: Date) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let expTimeString = SupabaseDateTransform.habitTimeString(from: expTime) ?? ""
                try await habitService.addHabit(
                    HabitItem(title: title, detail: detail, expTime: expTimeString)
                )
                notificationManager.scheduleHabitReminder(
                    title: title,
                    expTime: expTime,
                    notificationService: notificationService
                ) { [weak self] in
                    self?.onNotificationChanged?()
                }
                await loadData()
            } catch {
                print("Failed to add habit: \(error)")
            }
        }
    }

    func deleteHabit(_ habit: HabitItem) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await habitService.deleteHabit(id: habit.id)
                await loadData()
            } catch {
                print("Failed to delete habit: \(error)")
            }
        }
    }

    func toggleToday(_ habit: HabitItem) {
        let today = Date()

        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if habit.isCompleted(on: today) {
                    try await habitService.deleteHabitLog(habitId: habit.id, on: today)
                } else {
                    try await habitService.markHabitCompleted(id: habit.id, at: today)
                }
                await loadData()
            } catch {
                print("Failed to update habit completion: \(error)")
            }
        }
    }

    func streak(for habit: HabitItem) -> Int {
        var currentDate = Date()
        var days = 0

        while habit.completedDates.contains(DateKey(date: currentDate, calendar: calendar)) {
            days += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            currentDate = previous
        }
        return days
    }
}
