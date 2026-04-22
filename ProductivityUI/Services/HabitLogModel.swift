//
//  HabitLogModel.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//
import Foundation

struct HabitLogModel: Decodable {
    let id: String
    let habit_id: String
    let date: String
    let completed: Bool

    var dateValue: Date? {
        SupabaseDateTransform.parseDate(date)
    }
}

struct NewHabitLog: Encodable {
    let id: String
    let habit_id: String
    let date: String
    let completed: Bool
}
