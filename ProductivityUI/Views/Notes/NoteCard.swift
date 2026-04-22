import SwiftUI

struct NoteCard: View {
    let note: NoteItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(note.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(note.body)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)

            Text(note.updatedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.card)
        )
    }
}
