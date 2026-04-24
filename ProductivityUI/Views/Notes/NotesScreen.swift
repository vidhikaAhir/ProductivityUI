import SwiftUI

struct NotesScreen: View {
    @StateObject private var viewModel: NotesViewModel
    @State private var showCreate = false
    @State private var editingNote: NoteItem?
    @State private var searchText = ""

    init(viewModel: NotesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 12) {
                        if filteredNotes.isEmpty {
                            emptyState
                        } else {
                            ForEach(filteredNotes) { note in
                                NoteCard(note: note)
                                    .onTapGesture { editingNote = note }
                                    .contextMenu {
                                        Button("Delete", role: .destructive) {
                                            viewModel.deleteNote(note)
                                        }
                                    }
                            }
                        }
                    }
                    .padding()
                }

                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(AppTheme.accent))
                        .shadow(radius: 10, y: 4)
                }
                .padding()
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes")
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView("Updating notes...")
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .sheet(isPresented: $showCreate) {
            NoteEditorSheet(mode: .create) { title, body in
                viewModel.addNote(title: title, body: body)
            }
        }
        .sheet(item: $editingNote) { note in
            NoteEditorSheet(mode: .edit(note)) { title, body in
                viewModel.updateNote(note, title: title, body: body)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.and.pencil")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.note)
            Text("No notes yet")
                .font(.headline)
            Text("Create a note to load it.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var filteredNotes: [NoteItem] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return viewModel.notes }
        return viewModel.notes.filter {
            $0.title.localizedCaseInsensitiveContains(term) || $0.body.localizedCaseInsensitiveContains(term)
        }
    }
}
