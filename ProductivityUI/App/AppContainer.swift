import Foundation
import Combine

final class AppContainer: ObservableObject {
    let taskService: TaskServiceProtocol
    let noteService: NoteServiceProtocol
    let habitService: HabitServiceProtocol
    let profileService: ProfileServiceProtocol
    let notificationService: NotificationServiceProtocol

    init(
        taskService: TaskServiceProtocol = SupabaseTaskService(),
        noteService: NoteServiceProtocol = SupabaseNoteService(),
        habitService: HabitServiceProtocol = SupabaseHabitService(),
        profileService: ProfileServiceProtocol = SupabaseProfileService(),
        notificationService: NotificationServiceProtocol = InMemoryNotificationService()
    ) {
        self.taskService = taskService
        self.noteService = noteService
        self.habitService = habitService
        self.profileService = profileService
        self.notificationService = notificationService
    }
}

enum CalendarDestination {
    case tasks(TaskItem)
    case notes(NoteItem)
}
