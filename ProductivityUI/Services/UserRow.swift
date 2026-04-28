//
//  UserRow.swift
//  ConnectionofSupbase
//
//  Created by Apple on 20/04/26.
//
import Supabase
import Foundation
import UIKit
let supabaseQuery = SupabaseManager.shared.client

final class UserRowData {
    static let shared = UserRowData()
    private init() {}

    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to encode image"])
        }

        let fileName = "\(UUID().uuidString).jpg"
        let path = "uploads/\(fileName)"

        try await supabaseQuery.storage
            .from("images")
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))

        let publicURL = try supabaseQuery.storage
            .from("images")
            .getPublicURL(path: path)

        return publicURL.absoluteString
    }

    func addUser(id: String, username: String, email: String, phone: String, password: String, imageURL: String) async throws -> String {
        do {
            try await supabaseQuery
                .from("USERS")
                .insert(
                    NewUser(
                        id: id,
                        username: username,
                        email: email,
                        phone: phone,
                        password: password,
                        created_at: Date(),
                        image: imageURL
                    )
                )
                .execute()

            print("Insert success")
            return id
        } catch {
            print("Insert failed:", error)
            throw error
        }
    }

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
    func fetchSingleUser(id:String, password: String) async throws -> UserRow {
        do {
            let user: UserRow = try await supabaseQuery
                .from("USERS")
                .select()
                .eq("id", value: id)
                .eq("password", value: password)
                .single()
                .execute()
                .value

            print("User fetched:", user.id)
            return user
        } catch {
            print("Fetch failed:", error)
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

            print("User fetched:", user.id)
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
            print("Latest user fetched:", user.id)
            return user
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }

    func activeUserID() async throws -> String {
        if let currentUserID = await AppSession.shared.currentUserID {
            return currentUserID
        }

        throw AppSessionError.missingUserSession
    }

    func activeUser() async throws -> UserRow {
        if let currentUserID = await AppSession.shared.currentUserID {
            return try await fetchSingleUser(id: currentUserID)
        }

        throw AppSessionError.missingUserSession
    }


}
