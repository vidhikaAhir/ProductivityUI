//
//  UserRow.swift
//  ConnectionofSupbase
//
//  Created by Apple on 20/04/26.
//
import Supabase
import Foundation
let supabaseQuery = SupabaseManager.shared.client

final class UserRowData {
    static let shared = UserRowData()
    private init(){}
    func updateUser(id:String,username:String) async throws {
        do {
            try await supabaseQuery
                .from("USERS")
                .update([
                    "username": username
                ])
                .eq("id", value: id)
                .execute()

            print("Update success")
        } catch {
            print("Update failed:", error)
            throw error
        }
    }
    func fetchSingleUser(id:String) async throws -> UserRow {
        do {
            let user: UserRow = try await supabaseQuery
                .from("USERS")
                .select()
                .eq("id", value: id)
                .single()
                .execute()
                .value

            print("User:", user)
            return user
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }

    func fetchLatestUser() async throws -> UserRow {
        do {
            let user: UserRow = try await supabaseQuery
                .from("USERS")
                .select()
                .order("created_at", ascending: false)
                .limit(1)
                .single()
                .execute()
                .value
            print("Latest user:", user)
            return user
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }

    func activeUserID() async throws -> String {
        if let currentUserID = SupabaseManager.shared.client.auth.currentUser?.id.uuidString {
            return currentUserID
        }

        return try await fetchLatestUser().id
    }

    func activeUser() async throws -> UserRow {
        if let currentUserID = SupabaseManager.shared.client.auth.currentUser?.id.uuidString {
            return try await fetchSingleUser(id: currentUserID)
        }

        return try await fetchLatestUser()
    }


}
