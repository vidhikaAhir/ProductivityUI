import SwiftUI

struct HabitsScreen: View {
    @StateObject private var viewModel: HabitsViewModel
    @State private var showCreate = false

    init(viewModel: HabitsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        if viewModel.habits.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.habits) { habit in
                                HabitRow(
                                    habit: habit,
                                    streak: viewModel.streak(for: habit),
                                    isTodayDone: habit.isCompleted(on: Date()),
                                    onToggle: { viewModel.toggleToday(habit) }
                                )
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteHabit(habit)
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
            .navigationTitle("Habits")
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView("Updating habits...")
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .sheet(isPresented: $showCreate) {
            HabitEditorSheet { title, detail, expTime in
                viewModel.addHabit(title: title, detail: detail, expTime: expTime)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "leaf")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.habit)
            Text("No habits yet")
                .font(.headline)
            Text("Add a habit and track streaks.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
