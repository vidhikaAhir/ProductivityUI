import Foundation
import Combine

@MainActor
final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [NoteItem] = []
    @Published private(set) var isLoading = false

    private let noteService: NoteServiceProtocol

    init(noteService: NoteServiceProtocol) {
        self.noteService = noteService
        Task { await loadData() }
    }

    func refresh() {
        Task { await loadData() }
    }
    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }
        do {
            notes = try await noteService.fetchNotes()
        } catch {
            print("Failed to fetch notes: \(error)")
        }
    }

    func addNote(title: String, body: String) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await noteService.addNote(NoteItem(title: title, body: body))
                await loadData()
            } catch {
                print("Failed to add note: \(error)")
            }
        }
    }

    func updateNote(_ note: NoteItem, title: String, body: String) {
        var updated = note
        updated.title = title
        updated.body = body
        updated.updatedAt = Date()
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await noteService.updateNote(updated)
                await loadData()
            } catch {
                print("Failed to update note: \(error)")
            }
        }
    }

    func deleteNote(_ note: NoteItem) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                try await noteService.deleteNote(id: note.id)
                await loadData()
            } catch {
                print("Failed to delete note: \(error)")
            }
        }
    }
}
