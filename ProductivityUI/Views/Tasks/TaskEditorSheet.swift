import SwiftUI

struct TaskEditorSheet: View {
    enum Mode {
        case create
        case edit(TaskItem)
    }

    let mode: Mode
    let onSave: (String, String, Date?, Bool, TaskPriority) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var detail = ""
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    @State private var hasReminder = false
    @State private var priority: TaskPriority = .medium

    var body: some View {
        NavigationView {
            Form {
                Section("Task") {
                    TextField("What needs to be done?", text: $title)
                    TextField("Description", text: $detail, axis: .vertical)
                }

                Section("Schedule") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate)
                        Toggle("Set reminder", isOn: $hasReminder)
                    }
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { value in
                            Text(value.rawValue.capitalized).tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(modeTitle)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, detail, hasDueDate ? dueDate : nil, hasReminder, priority)
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
        case .create: return "Create Task"
        case .edit: return "Edit Task"
        }
    }

    private func setInitialValue() {
        guard case let .edit(task) = mode else { return }
        title = task.title
        detail = task.detail
        priority = task.priority
        hasReminder = task.hasReminder
        if let due = task.dueDate {
            hasDueDate = true
            dueDate = due
        }
    }
}
