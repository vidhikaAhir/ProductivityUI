import SwiftUI

struct CalendarNotificationsSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                if viewModel.unviewedNotifications.isEmpty == false {
                    Section("Unviewed") {
                        ForEach(viewModel.unviewedNotifications) { item in
                            notificationRow(item, isViewed: false)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.markNotificationAsViewed(item)
                                }
                        }
                    }
                }

                Section("Viewed") {
                    if viewModel.viewedNotifications.isEmpty {
                        Text("No viewed notifications yet.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.viewedNotifications) { item in
                            notificationRow(item, isViewed: true)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Mark all viewed") {
                        viewModel.markAllNotificationsAsViewed()
                    }
                    .disabled(viewModel.unviewedCount == 0)
                }
            }
        }
    }

    private func notificationRow(_ item: AppNotificationItem, isViewed: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(isViewed ? Color.gray.opacity(0.35) : AppTheme.accent)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.weight(isViewed ? .regular : .bold))
                    .foregroundColor(isViewed ? .secondary : .primary)
                Text(item.message)
                    .font(.subheadline)
                    .foregroundColor(isViewed ? .secondary : .primary)
                Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
