import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appContainer: AppContainer
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var calendarViewModel: CalendarViewModel
    @StateObject private var tasksViewModel: TasksViewModel
    @StateObject private var notesViewModel: NotesViewModel
    @StateObject private var habitsViewModel: HabitsViewModel
    @StateObject private var profileViewModel: ProfileViewModel
    @State private var selectedTab: AppTab = .calendar
    @State private var spotlightFrames: [SpotlightFrameTarget: CGRect] = [:]

    init() {
        let taskService = SupabaseTaskService()
        let noteService = SupabaseNoteService()
        let habitService = SupabaseHabitService()
        let profileService = SupabaseProfileService()
        let notificationService = InMemoryNotificationService()
        let calendarVM = CalendarViewModel(
            taskService: taskService,
            noteService: noteService,
            habitService: habitService,
            notificationService: notificationService
        )
        let tasksVM = TasksViewModel(taskService: taskService)
        let notesVM = NotesViewModel(noteService: noteService)
        let habitsVM = HabitsViewModel(
            habitService: habitService,
            notificationService: notificationService,
            onNotificationChanged: {
                Task { @MainActor in
                    calendarVM.refresh()
                }
            }
        )
        let profileVM = ProfileViewModel(profileService: profileService)

        _calendarViewModel = StateObject(wrappedValue: calendarVM)
        _tasksViewModel = StateObject(wrappedValue: tasksVM)
        _notesViewModel = StateObject(wrappedValue: notesVM)
        _habitsViewModel = StateObject(wrappedValue: habitsVM)
        _profileViewModel = StateObject(wrappedValue: profileVM)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                TabView(selection: $selectedTab) {
                    CalendarScreen(viewModel: calendarViewModel, taskViewModel: tasksViewModel, noteViewModel: notesViewModel)
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(AppTab.calendar)

                    TasksScreen(viewModel: tasksViewModel)
                        .tabItem {
                            Label("Tasks", systemImage: "checklist")
                        }
                        .tag(AppTab.tasks)

                    NotesScreen(viewModel: notesViewModel)
                        .tabItem {
                            Label("Notes", systemImage: "square.and.pencil")
                        }
                        .tag(AppTab.notes)

                    HabitsScreen(viewModel: habitsViewModel)
                        .tabItem {
                            Label("Habits", systemImage: "leaf")
                        }
                        .tag(AppTab.habits)

                    ProfileScreen(viewModel: profileViewModel)
                        .tabItem {
                            Label("Profile", systemImage: "person")
                        }
                        .tag(AppTab.profile)
                }
                .onPreferenceChange(SpotlightFramePreferenceKey.self) { value in
                    spotlightFrames = value
                }

                if let step = onboardingViewModel.currentStep, onboardingViewModel.isVisible {
                    SpotlightView(
                        rect: spotlightRect(for: step.target, in: proxy),
                        title: step.title,
                        message: step.message,
                        stepText: onboardingViewModel.stepNumberText,
                        canGoBack: onboardingViewModel.canGoBack,
                        onBack: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboardingViewModel.back()
                                syncTabWithCurrentStep()
                            }
                        },
                        onNext: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboardingViewModel.next()
                                syncTabWithCurrentStep()
                            }
                        },
                        onSkip: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                onboardingViewModel.skip()
                            }
                        }
                    )
                    .zIndex(999)
                }
            }
            .tint(.purple)
            .onAppear(perform: syncTabWithCurrentStep)
        }
    }

    private func syncTabWithCurrentStep() {
        guard let step = onboardingViewModel.currentStep else { return }
        selectedTab = onboardingViewModel.preferredTab(for: step)
    }

    private func spotlightRect(for target: OnboardingTarget, in proxy: GeometryProxy) -> CGRect {
        let safeBottom = proxy.safeAreaInsets.bottom
        let tabBarHeight: CGFloat = 49 + safeBottom
        let tabBarTop = proxy.size.height - tabBarHeight
        let sectionWidth = proxy.size.width / CGFloat(AppTab.allCases.count)

        func tabRect(for tab: AppTab) -> CGRect {
            let x = sectionWidth * CGFloat(tab.rawValue)
            return CGRect(x: x + 8, y: tabBarTop + 2, width: max(sectionWidth - 16, 30), height: 44)
        }

        switch target {
        case .calendarTab:
            return tabRect(for: .calendar)
        case .tasksTab:
            return tabRect(for: .tasks)
        case .notesTab:
            return tabRect(for: .notes)
        case .habitsTab:
            return tabRect(for: .habits)
        case .profileTab:
            return tabRect(for: .profile)
        case .addButton:
            if let frame = spotlightFrames[.addButton] {
                return frame
            }
            return CGRect(
                x: proxy.size.width - 92,
                y: proxy.size.height - tabBarHeight - 94,
                width: 56,
                height: 56
            )
        }
    }
}
