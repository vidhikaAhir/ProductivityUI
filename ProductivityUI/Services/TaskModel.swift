//
//  TaskModel.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//
import Foundation

struct TaskModel: Decodable {
    let id: String
    let user_id: String
    let title: String
    let description: String?
    let due_date: String?
    let due_time: String?
    let reminder: Bool
    let priority: String
    let is_completed: Bool
    let created_at: String?

    var dueDateValue: Date? {
        SupabaseDateTransform.parseDate(due_date)
    }

    var priorityValue: TaskPriority {
        TaskPriority(supabaseRawValue: priority)
    }
}

struct NewTask: Encodable {
    let id:String
    let user_id: String
    let title: String
    let description: String?
    let due_date: String?
    let due_time: String?
    let reminder: Bool
    let priority: String
    let is_completed: Bool
}

struct UpdateTask: Encodable {
    let title: String
    let description: String
    let priority: String
    let is_completed: Bool
    let due_date: String?
    let due_time: String?
    let reminder: Bool
}
