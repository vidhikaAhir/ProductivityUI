//
//  HabitsRow.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//
import Supabase
import Foundation
final class HabitsRow {
    static let shared = HabitsRow()
    private init() {}
    func addHabit(id:String,user_id:String,title:String,duration:String) async throws {
        do {
            try await supabaseQuery
                .from("HABITS")
                .insert(
                    NewHabit(
                        id: id,
                        user_id: user_id,
                        title: title,
                        duration: duration,
                        created_at: Date()
                    )
                )
                .execute()

            print("Habit inserted successfully")
        } catch {
            print("Insert failed:", error)
            throw error
        }
    }
    
    func fetchHabits(user_id:String) async throws -> [HabitModel] {
        do {
            let habits: [HabitModel] = try await supabaseQuery
                .from("HABITS")
                .select()
                .eq("user_id", value: user_id)
                .execute()
                .value

            print("Habits:", habits)
            return habits
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }
    func updateHabit(title:String,duration:String,id:String) async throws {
        do {
            try await supabaseQuery
                .from("HABITS")
                .update(
                    UpdateHabit(
                        title: title,
                        duration: duration
                    )
                )
                .eq("id", value:id)
                .execute()

            print("Habit updated successfully")
        } catch {
            print("Update failed:", error)
            throw error
        }
    }
    
    func deleteHabit(id:String) async throws {
        do {
            try await supabaseQuery
                .from("HABITS")
                .delete()
                .eq("id", value: id)
                .execute()

            print("Habit deleted successfully")
        } catch {
            print("Delete failed:", error)
            throw error
        }
    }

}
