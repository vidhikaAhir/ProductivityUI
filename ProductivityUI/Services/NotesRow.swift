//
//  NotesRow.swift
//  ConnectionofSupbase
//
//  Created by Apple on 21/04/26.
//

import Foundation
import Supabase

public class NotesRow {
    static let shared = NotesRow()
    private init() {}
    func addNote(id:String, user_id:String, title:String, subtitle:String, content:String) async throws {
        do {
            try await supabaseQuery
                .from("NOTES")
                .insert(
                    NewNote(
                        id: id,
                        user_id: user_id,
                        title: title,
                        subtitle: subtitle,
                        content: content,
                        created_at: Date()
                    )
                )
                .execute()

            print("Note inserted successfully")
        } catch {
            print("Insert failed:", error)
            throw error
        }
    }
    
    func fetchNotes(user_id:String) async throws -> [NoteModel] {
        do {
            let notes: [NoteModel] = try await supabaseQuery
                .from("NOTES")
                .select()
                .eq("user_id", value: user_id)
                .execute()
                .value

            print("Notes:", notes)
            return notes
        } catch {
            print("Fetch failed:", error)
            throw error
        }
    }

    func updateNote(title:String,subtitle:String,content:String,id:String) async throws {
        do {
            try await supabaseQuery
                .from("NOTES")
                .update(
                    UpdateNote(
                        title: title,
                        subtitle: subtitle,
                        content: content
                    )
                )
                .eq("id", value: id)
                .execute()

            print("Note updated successfully")
        } catch {
            print("Update failed:", error)
            throw error
        }
    }

    func deleteNote(id:String) async throws {
        do {
            try await supabaseQuery
                .from("NOTES")
                .delete()
                .eq("id", value: id)
                .execute()

            print("Note deleted successfully")
        } catch {
            print("Delete failed:", error)
            throw error
        }
    }

}
