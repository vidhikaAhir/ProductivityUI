import Foundation

protocol NoteServiceProtocol {
    func fetchNotes() async throws -> [NoteItem]
    func addNote(_ note: NoteItem) async throws
    func updateNote(_ note: NoteItem) async throws
    func deleteNote(id: UUID) async throws
}

final class SupabaseNoteService: NoteServiceProtocol {
    init() {}

    func fetchNotes() async throws -> [NoteItem] {
        let userID = try await UserRowData.shared.activeUserID()
        let rows = try await NotesRow.shared.fetchNotes(user_id: userID)
        return rows.map(NoteItem.init(from:))
    }

    func addNote(_ note: NoteItem) async throws {
        let userID = try await UserRowData.shared.activeUserID()
        try await NotesRow.shared.addNote(
            id: note.id.uuidString,
            user_id: userID,
            title: note.title,
            subtitle: String(note.body.prefix(80)),
            content: note.body
        )
    }

    func updateNote(_ note: NoteItem) async throws {
        try await NotesRow.shared.updateNote(
            title: note.title,
            subtitle: String(note.body.prefix(80)),
            content: note.body,
            id: note.id.uuidString
        )
    }

    func deleteNote(id: UUID) async throws {
        try await NotesRow.shared.deleteNote(id: id.uuidString)
    }
}
