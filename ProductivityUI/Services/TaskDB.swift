//
//  TaskRow.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//
import Supabase
import Foundation
final class TaskDB {
    static let shared = TaskDB()
    private init(){}
    func addTask(id:String,user_id:String,title:String,description:String,due_date:String?,due_time:String?,reminder:Bool,priority:String,is_completed:Bool) async throws {
        do {
            try await supabaseQuery
                .from("TASKS")
                .insert(
                    NewTask(
                        id: id,
                        user_id: user_id,
                        title: title,
                        description: description,
                        due_date: due_date,
                        due_time: due_time,
                        reminder: reminder,
                        priority: priority,
                        is_completed: is_completed
                    )
                )
                .execute()
            
            print("Task inserted successfully")
        } catch {
            print("Insert failed:", error)
            throw error
        }
    }
    func fetchTasks(user_id:String) async throws -> [TaskModel] {
        do {
            let tasks: [TaskModel] = try await supabaseQuery
                .from("TASKS")
                .select()
                .eq("user_id", value: user_id)
                .execute()
                .value
            
            print("Tasks:", tasks)
            return tasks
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }
    func updateTask(title:String,description:String,priority:String,is_completed:Bool,due_date:String?,due_time:String?,reminder:Bool,id:String) async throws {
        do {
            try await supabaseQuery
                .from("TASKS")
                .update(
                    UpdateTask(
                        title: title,
                        description: description,
                        priority: priority,
                        is_completed: is_completed,
                        due_date: due_date,
                        due_time: due_time,
                        reminder: reminder
                    )
                )
                .eq("id", value: id)
                .execute()
            
            print("Task updated successfully")
        } catch {
            print("Update failed:", error)
            throw error
        }
    }
    
    func deleteTask(id:String) async throws {
        do {
            try await supabaseQuery
                .from("TASKS")
                .delete()
                .eq("id", value: id)
                .execute()
            
            print("Task deleted successfully")
        } catch {
            print("Delete failed:", error)
            throw error
        }
    }
    
}
