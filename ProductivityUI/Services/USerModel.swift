//
//  USerModel.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//
import Foundation
struct UserRow: Decodable {
    let id: String
    let username: String?
    let email: String?
    let phone: String?
    let created_at: Date
}
