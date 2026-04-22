import SwiftUI

struct NoteEditorSheet: View {
    enum Mode {
        case create
        case edit(NoteItem)
    }

    let mode: Mode
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var bodyText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                TextEditor(text: $bodyText)
                    .frame(maxHeight: .infinity)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
            .padding()
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, bodyText)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear(perform: setInitialValue)
    }

    private var modeTitle: String {
        switch mode {
        case .create: return "Create Note"
        case .edit: return "Edit Note"
        }
    }

    private func setInitialValue() {
        guard case let .edit(note) = mode else { return }
        title = note.title
        bodyText = note.body
    }
}
