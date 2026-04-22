import SwiftUI

struct TasksScreen: View {
    @StateObject private var viewModel: TasksViewModel
    @State private var showCreate = false
    @State private var editingTask: TaskItem?

    init(viewModel: TasksViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottomTrailing) {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Picker("", selection: $viewModel.selectedFilter) {
                            ForEach(TasksViewModel.Filter.allCases) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)

                        if viewModel.filteredTasks.isEmpty {
                            emptyState
                        } else {
                            ForEach(viewModel.filteredTasks) { task in
                                TaskRow(task: task, onToggle: {
                                    viewModel.toggleCompletion(task)
                                }, onTap: {
                                    editingTask = task
                                })
                                .contextMenu {
                                    Button("Delete", role: .destructive) {
                                        viewModel.deleteTask(task)
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
                .spotlightFrame(target: .addButton)
            }
            .navigationTitle("Tasks")
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView("Updating tasks...")
                }
            }
        }
        .refreshable {
            viewModel.refresh()
        }
        .onChange(of: externalEditingTask) { newValue in
            guard let newValue else { return }
            editingTask = newValue
            externalEditingTask = nil
        }
        .sheet(isPresented: $showCreate) {
            TaskEditorSheet(mode: .create) { title, detail, dueDate, reminder, priority in
                viewModel.addTask(title: title, detail: detail, dueDate: dueDate, hasReminder: reminder, priority: priority)
            }
        }
        .sheet(item: $editingTask) { task in
            TaskEditorSheet(mode: .edit(task)) { title, detail, dueDate, reminder, priority in
                var updated = task
                updated.title = title
                updated.detail = detail
                updated.dueDate = dueDate
                updated.hasReminder = reminder
                updated.priority = priority
                viewModel.updateTask(updated)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "checklist")
                .font(.system(size: 34))
                .foregroundColor(AppTheme.accent)
            Text("No tasks yet")
                .font(.headline)
            Text("Create a task to start pulling data from Supabase.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
