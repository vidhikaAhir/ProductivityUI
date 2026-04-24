# ProductivityUI Flow Guide

This project is a SwiftUI productivity app built around a simple MVVM-style flow:

- `App` bootstraps the app and chooses the first screen.
- `ViewModels` hold screen state and async operations.
- `Services` talk to Supabase, local notification APIs, and in-memory notification state.
- `Models` convert backend rows into app-friendly data structures.
- `Views` render UI and call into the view models.

## 1. App Startup

The app begins in [`ProductivityUI/ProductivityUIApp.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ProductivityUIApp.swift).

Startup sequence:

1. `ProductivityUIApp` creates the root scene.
2. `AppGateView` decides whether to show `LoginScreen` or `RootTabView`.
3. `AppSession` reads the saved `user_id` from `UserDefaults`.
4. If a session exists, the app shows the main workspace.
5. The app also requests notification permission on launch.

## 2. Login and Session Flow

The login flow lives in:

- [`ProductivityUI/Views/Login/LoginScreen.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Views/Login/LoginScreen.swift)
- [`ProductivityUI/Views/Login/LoginViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Views/Login/LoginViewModel.swift)
- [`ProductivityUI/App/AppSession.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/App/AppSession.swift)

How it works:

1. The user enters username, email, phone number, and avatar.
2. `LoginViewModel.createUser(...)` uploads the image.
3. The user row is created in Supabase.
4. The phone number is stored as the active `user_id`.
5. `AppSession.setUserID(...)` persists the session in `UserDefaults`.
6. `AppGateView` sees `isLoggedIn == true` and switches to the main tab shell.

This is the main authentication state for the current app structure.

## 3. Main Screen Shell

The primary workspace is [`ProductivityUI/App/RootTabView.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/App/RootTabView.swift).

It owns:

- the tab bar
- the onboarding spotlight overlay
- the feature view models
- the shared notification service

Tabs:

- Calendar
- Tasks
- Notes
- Habits
- Profile

The tab shell also keeps onboarding in sync with the currently highlighted tab.

## 4. Data Flow Pattern

Each feature generally follows the same pattern:

1. A SwiftUI view displays a screen.
2. The screen uses a `ViewModel`.
3. The view model calls a protocol-based service.
4. The service talks to Supabase or local storage.
5. Returned rows are converted into app models.
6. The view model publishes new state back to the UI.

This keeps UI code thin and makes the async work easier to reason about.

## 5. Feature Flows

### Calendar

Main files:

- [`ProductivityUI/ViewModels/CalendarViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/CalendarViewModel.swift)
- [`ProductivityUI/Views/Calendar/CalendarScreen.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Views/Calendar/CalendarScreen.swift)

Calendar responsibilities:

- load tasks, notes, habits, and notifications together
- build a merged day feed for the selected date
- show reminder counts and viewed/unviewed notification groups
- provide day dots and month grid data

The calendar is the aggregation layer of the app. It combines data from the other feature stores instead of owning its own separate dataset.

### Tasks

Main files:

- [`ProductivityUI/ViewModels/TasksViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/TasksViewModel.swift)
- [`ProductivityUI/Services/TaskService.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/TaskService.swift)
- [`ProductivityUI/Services/TaskDB.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/TaskDB.swift)

Task flow:

1. `TasksViewModel` loads the task list.
2. User actions create, update, delete, or toggle completion.
3. `SupabaseTaskService` maps app models to Supabase row fields.
4. `TaskDB` performs the actual Supabase queries.
5. The view model refreshes its list after each write.

### Notes

Main files:

- [`ProductivityUI/ViewModels/NotesViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/NotesViewModel.swift)
- [`ProductivityUI/Services/NoteService.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/NoteService.swift)

Notes follow the same pattern as tasks:

- load note rows from Supabase
- map them into `NoteItem`
- update local published state
- reload after mutations

### Habits

Main files:

- [`ProductivityUI/ViewModels/HabitsViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/HabitsViewModel.swift)
- [`ProductivityUI/Services/HabitService.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/HabitService.swift)
- [`ProductivityUI/Services/NotificationManager.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/NotificationManager.swift)

Habit flow:

1. The view model loads habits from Supabase.
2. A new habit is saved through the service layer.
3. A reminder notification may be scheduled for the habit.
4. Habit completion is tracked through habit logs.
5. The calendar refreshes when notification state changes.

Habit completion is date-based, so the model keeps a set of normalized day keys instead of full timestamps.

### Profile

Main files:

- [`ProductivityUI/ViewModels/ProfileViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/ProfileViewModel.swift)
- [`ProductivityUI/Services/ProfileService.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/ProfileService.swift)

Profile flow:

- fetch the active user row
- display the profile in the UI
- update editable fields back to Supabase

## 6. Models and Transformations

The `Models/` folder contains the app-facing data types:

- `TaskItem`
- `NoteItem`
- `HabitItem`
- `AppNotificationItem`
- `CalendarFeedItem`
- `HabitFrequency`

These types are the bridge between raw backend rows and the UI.

Notable behavior:

- `TaskItem`, `NoteItem`, and `HabitItem` each provide initializers that map from Supabase row types.
- `HabitItem` includes calendar helpers such as recurrence checks and completion checks.
- `AppNotificationItem` stores local notification state and viewed state.

## 7. Notification Flow

Notifications are handled by two pieces:

- [`ProductivityUI/Services/NotificationManager.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/NotificationManager.swift)
- [`ProductivityUI/Services/NotificationService.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/Services/NotificationService.swift)

Current behavior:

- `NotificationManager` asks iOS for notification permission.
- Habit reminders can schedule a one-hour-before alert.
- `InMemoryNotificationService` stores notification items, persists them in `UserDefaults`, and syncs task reminders into the notification list.
- The calendar view model reads from that service to show viewed and unviewed items.

## 8. Supabase Layer

The Supabase boundary is split into two parts:

- service protocols and app-level services in `Services/*.swift`
- row/database access helpers such as `TaskDB`, `NotesRow`, `HabitsRow`, and `UserRow`

The general rule is:

1. `ViewModel` asks a protocol service for work.
2. The service checks the active user.
3. The service calls the row/database helper.
4. The helper performs the actual query.
5. The service maps returned rows into app models.

This keeps the UI layer independent from the database schema.

## 9. Code Process

When adding or changing a feature, the codebase usually moves in this order:

1. Update the model if the shape of data changed.
2. Update the service protocol and service implementation.
3. Update the view model to load or mutate the new state.
4. Update the SwiftUI screen and any reusable row/editor views.
5. Verify the calendar or notification aggregations still make sense.
6. Keep async work on the main actor when it mutates published UI state.
7. Refresh lists after writes so the UI stays in sync with Supabase.

## 10. Practical Reading Order

If you are trying to understand the app quickly, read in this order:

1. [`ProductivityUI/ProductivityUIApp.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ProductivityUIApp.swift)
2. [`ProductivityUI/App/AppGateView.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/App/AppGateView.swift)
3. [`ProductivityUI/App/RootTabView.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/App/RootTabView.swift)
4. [`ProductivityUI/ViewModels/CalendarViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/CalendarViewModel.swift)
5. [`ProductivityUI/ViewModels/TasksViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/TasksViewModel.swift)
6. [`ProductivityUI/ViewModels/NotesViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/NotesViewModel.swift)
7. [`ProductivityUI/ViewModels/HabitsViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/HabitsViewModel.swift)
8. [`ProductivityUI/ViewModels/ProfileViewModel.swift`](/Users/neo/Desktop/untitled%20folder/ProductivityUI/ProductivityUI/ViewModels/ProfileViewModel.swift)

That path shows the full app lifecycle from launch to data loading to user actions.
