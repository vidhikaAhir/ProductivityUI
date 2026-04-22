import Foundation
import Combine

final class HabitsViewModel: ObservableObject {
    @Published private(set) var habits: [HabitItem] = []

    private let habitService: HabitServiceProtocol
    private let calendar = Calendar.current

    init(habitService: HabitServiceProtocol) {
        self.habitService = habitService
        Task { await loadData() }
    }

    func refresh() {
        Task { await loadData() }
    }

    func loadData() async {
        do {
            habits = try await habitService.fetchHabits()
        } catch {
            print("Failed to fetch habits: \(error)")
        }
    }

    func addHabit(title: String, detail: String) {
        Task {
            do {
                try await habitService.addHabit(HabitItem(title: title, detail: detail))
                await loadData()
            } catch {
                print("Failed to add habit: \(error)")
            }
        }
    }

    func deleteHabit(_ habit: HabitItem) {
        Task {
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
