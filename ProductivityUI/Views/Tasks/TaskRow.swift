import SwiftUI

struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void
    let onTap: () -> Void

    private var statusTint: Color {
        switch task.priority {
        case .low: return .green
        case .medium: return AppTheme.task
        case .high: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(task.isCompleted ? .green : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(task.title)
                            .font(.headline)
                            .foregroundColor(task.isCompleted ? .secondary : .primary)
                            .strikethrough(task.isCompleted, color: .secondary)

                        Spacer()

                        Text(task.priority.rawValue.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(statusTint)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(statusTint.opacity(0.14)))
                    }

                    if !task.detail.isEmpty {
                        Text(task.detail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            HStack(spacing: 10) {
                if let dueDate = task.dueDate {
                    Label(dueDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                }

                if task.hasReminder {
                    Label("Reminder", systemImage: "bell.badge")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(AppTheme.reminder)
                }

                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(task.isCompleted ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
