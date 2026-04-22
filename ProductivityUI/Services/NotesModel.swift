import Foundation

struct NoteModel: Decodable {
    let id: String
    let user_id: String
    let title: String
    let subtitle: String?
    let content: String?
    let created_at: String?
}

struct NewNote: Encodable {
    let id: String
    let user_id: String
    let title: String
    let subtitle: String?
    let content: String?
    let created_at: Date
}

struct UpdateNote: Encodable {
    let title: String
    let subtitle: String?
    let content: String?
}
//
//  NotesModel.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//

