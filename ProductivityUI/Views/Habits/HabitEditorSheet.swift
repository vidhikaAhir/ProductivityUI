import SwiftUI

struct HabitEditorSheet: View {
    let onSave: (String, String, Date) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var expTime = Date()

    enum HabitFrequency: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"

        var id: String { rawValue }
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Habit name", text: $title)
                Picker("Frequency", selection: $frequency) {
                    ForEach(HabitFrequency.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                DatePicker(
                    "End Time",
                    selection: $expTime,
                    displayedComponents: .hourAndMinute
                )
            }
            .navigationTitle("Create Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, frequency.rawValue, expTime)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
