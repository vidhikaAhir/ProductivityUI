import Foundation

enum HabitFrequency: String, CaseIterable, Identifiable, Codable {
    case daily
    case weekly
    case monthly

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    init(storedValue: String) {
        self = HabitFrequency(rawValue: storedValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()) ?? .daily
    }
}
