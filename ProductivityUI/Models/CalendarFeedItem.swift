import Foundation

enum CalendarFeedType {
    case task(TaskItem)
    case note(NoteItem)
    case habit(HabitItem)
    case reminder(TaskItem)

    var tintName: String {
        switch self {
        case .task:
            return "task"
        case .note:
            return "note"
        case .habit:
            return "habit"
        case .reminder:
            return "reminder"
        }
    }
}

struct CalendarFeedItem: Identifiable {
    let id: UUID
    let date: Date
    let title: String
    let subtitle: String
    let type: CalendarFeedType
}
