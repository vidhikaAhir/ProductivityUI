import Foundation

protocol HabitServiceProtocol {
    func fetchHabits() async throws -> [HabitItem]
    func fetchHabitLogs() async throws -> [HabitLog]
    func addHabit(_ habit: HabitItem) async throws
    func updateHabit(_ habit: HabitItem) async throws
    func deleteHabit(id: UUID) async throws
    func markHabitCompleted(id: UUID, at date: Date) async throws
    func deleteHabitLog(habitId: UUID, on date: Date) async throws
}

final class SupabaseHabitService: HabitServiceProtocol {
    init() {}

    func fetchHabits() async throws -> [HabitItem] {
        let userID = try await UserRowData.shared.activeUserID()
        let habitRows = try await HabitsRow.shared.fetchHabits(user_id: userID)
        var items: [HabitItem] = []

        for row in habitRows {
            let logs = try await HabitLogRow.shared.fetchHabitLogs(habit_id: row.id)
            items.append(HabitItem(from: row, logs: logs))
        }

        return items.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchHabitLogs() async throws -> [HabitLog] {
        let userID = try await UserRowData.shared.activeUserID()
        let habits = try await HabitsRow.shared.fetchHabits(user_id: userID)
        var allLogs: [HabitLog] = []

        for habit in habits {
            let logs = try await HabitLogRow.shared.fetchHabitLogs(habit_id: habit.id).map {
                HabitLog(id: UUID(uuidString: $0.id) ?? UUID(), habitId: UUID(uuidString: $0.habit_id) ?? UUID(), completedAt: $0.dateValue ?? Date())
            }
            allLogs.append(contentsOf: logs)
        }

        return allLogs
    }

    func addHabit(_ habit: HabitItem) async throws {
        let userID = try await UserRowData.shared.activeUserID()
        try await HabitsRow.shared.addHabit(
            id: habit.id.uuidString,
            user_id: userID,
            title: habit.title,
            duration: habit.detail
        )
    }

    func updateHabit(_ habit: HabitItem) async throws {
        try await HabitsRow.shared.updateHabit(
            title: habit.title,
            duration: habit.detail,
            id: habit.id.uuidString
        )
    }

    func deleteHabit(id: UUID) async throws {
        try await HabitsRow.shared.deleteHabit(id: id.uuidString)
    }

    func markHabitCompleted(id: UUID, at date: Date = Date()) async throws {
        try await HabitLogRow.shared.addHabitLog(
            id: UUID().uuidString,
            habit_id: id.uuidString,
            date: SupabaseDateTransform.dateString(from: date) ?? SupabaseDateTransform.dateOnlyFormatter.string(from: date),
            completed: true
        )
    }

    func deleteHabitLog(habitId: UUID, on date: Date) async throws {
        let day = DateKey(date: date)
        let logs = try await HabitLogRow.shared.fetchHabitLogs(habit_id: habitId.uuidString).filter {
            guard let logDate = $0.dateValue else { return false }
            return DateKey(date: logDate) == day
        }

        for log in logs {
            try await HabitLogRow.shared.deleteHabitLog(id: log.id)
        }
    }
}
