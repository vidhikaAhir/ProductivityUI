import Foundation
import Supabase

final class HabitLogRow {
    static let shared = HabitLogRow()
    private init(){}
    func addHabitLog(id:String,habit_id:String,date:String,completed:Bool) async throws {
        do {
            try await supabaseQuery
                .from("HABIT_LOGS")
                .insert(
                    NewHabitLog(
                        id: id,
                        habit_id: habit_id,
                        date: date,
                        completed: completed
                    )
                )
                .execute()

            print("Habit log inserted successfully")
        } catch {
            print("Insert failed:", error)
            throw error
        }
    }
    
    func fetchHabitLogs(habit_id:String) async throws -> [HabitLogModel] {
        do {
            let logs: [HabitLogModel] = try await supabaseQuery
                .from("HABIT_LOGS")
                .select()
                .eq("habit_id", value: habit_id)
                .execute()
                .value

            print("Habit logs:", logs)
            return logs
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }

    func deleteHabitLog(id:String) async throws {
        do {
            try await supabaseQuery
                .from("HABIT_LOGS")
                .delete()
                .eq("id", value: id)
                .execute()

            print("Habit log deleted successfully")
        } catch {
            print("Delete failed:", error)
            throw error
        }
    }

}
