import SwiftUI

struct HabitRow: View {
    let habit: HabitItem
    let streak: Int
    let isTodayDone: Bool
    let onToggle: () -> Void

    private var progressTint: Color {
        isTodayDone ? AppTheme.habit : .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: isTodayDone ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isTodayDone ? .green : .secondary)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(habit.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("\(streak) day streak")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(AppTheme.habit)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(AppTheme.habit.opacity(0.14)))
                    }

                    if !habit.detail.isEmpty {
                        Text(habit.detail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }

            HStack {
                Label(isTodayDone ? "Done today" : "Pending today", systemImage: isTodayDone ? "checkmark.seal.fill" : "clock")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(progressTint)

                Spacer()

                Text(habit.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(AppTheme.card)
        )
    }
}
