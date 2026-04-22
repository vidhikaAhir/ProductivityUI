//
//  HabitsModel.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//

import Foundation

struct HabitModel: Decodable {
    let id: String
    let user_id: String
    let title: String
    let duration: String
    let created_at: String?

    var createdAtValue: Date? {
        SupabaseDateTransform.parseDate(created_at)
    }
}

struct NewHabit: Encodable {
    let id: String
    let user_id: String
    let title: String
    let duration: String
    let created_at: Date
}

struct UpdateHabit: Encodable {
    let title: String
    let duration: String
}
