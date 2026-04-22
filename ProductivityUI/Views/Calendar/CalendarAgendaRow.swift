import SwiftUI

struct CalendarAgendaRow: View {
    let item: CalendarFeedItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))
        }
        .buttonStyle(.plain)
    }

    private var dotColor: Color {
        switch item.type {
        case .task:
            return AppTheme.task
        case .note:
            return AppTheme.note
        case .habit:
            return AppTheme.habit
        case .reminder:
            return AppTheme.reminder
        }
    }
}
