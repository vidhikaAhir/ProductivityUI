import Foundation
import Combine

enum AppTab: Int, CaseIterable {
    case calendar
    case tasks
    case notes
    case habits
    case profile
}

enum OnboardingTarget {
    case calendarTab
    case tasksTab
    case notesTab
    case habitsTab
    case addButton
    case profileTab
}

struct OnboardingStep: Identifiable {
    let id = UUID()
    let target: OnboardingTarget
    let title: String
    let message: String
}

final class OnboardingViewModel: ObservableObject {
    @Published private(set) var isVisible: Bool
    @Published private(set) var currentIndex: Int = 0

    private let defaults: UserDefaults
    private let completionKey = "onboardingCompleted"

    let steps: [OnboardingStep] = [
        OnboardingStep(target: .calendarTab, title: "Calendar", message: "Check your monthly plan and daily schedule here."),
        OnboardingStep(target: .tasksTab, title: "Tasks", message: "Manage to-dos, due dates, and reminders."),
        OnboardingStep(target: .notesTab, title: "Notes", message: "Capture quick notes and ideas in one place."),
        OnboardingStep(target: .habitsTab, title: "Habits", message: "Track daily habits and build streaks."),
        OnboardingStep(target: .addButton, title: "Quick Add", message: "Use the + button to quickly create a new item."),
        OnboardingStep(target: .profileTab, title: "Profile", message: "Open your profile for account and preferences.")
    ]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isVisible = defaults.bool(forKey: completionKey) == false
    }

    var currentStep: OnboardingStep? {
        guard steps.indices.contains(currentIndex), isVisible else { return nil }
        return steps[currentIndex]
    }

    var canGoBack: Bool { currentIndex > 0 }
    var stepNumberText: String { "\(currentIndex + 1) / \(steps.count)" }

    func next() {
        guard isVisible else { return }
        if currentIndex < steps.count - 1 {
            currentIndex += 1
        } else {
            finish()
        }
    }

    func back() {
        guard canGoBack else { return }
        currentIndex -= 1
    }

    func skip() {
        finish()
    }

    func finish() {
        defaults.set(true, forKey: completionKey)
        isVisible = false
    }

    func preferredTab(for step: OnboardingStep) -> AppTab {
        switch step.target {
        case .calendarTab: return .calendar
        case .tasksTab, .addButton: return .tasks
        case .notesTab: return .notes
        case .habitsTab: return .habits
        case .profileTab: return .profile
        }
    }
}
