import Foundation

enum SupabaseDateTransform {
    static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let timeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    static let habitTimeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    static func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        if let date = isoFormatter.date(from: raw) {
            return date
        }
        if let date = dateOnlyFormatter.date(from: raw) {
            return date
        }
        if let date = timeOnlyFormatter.date(from: raw) {
            return date
        }
        if let date = habitTimeOnlyFormatter.date(from: raw) {
            return date
        }
        return nil
    }

    static func combineDate(due_date: String?, due_time: String?) -> Date? {
        guard let dueDateString = due_date,
              let day = dateOnlyFormatter.date(from: dueDateString) else {
            return nil
        }

        guard let dueTimeString = due_time, dueTimeString.isEmpty == false else {
            return day
        }

        let timeParser = DateFormatter()
        timeParser.calendar = Calendar(identifier: .gregorian)
        timeParser.locale = Locale(identifier: "en_US_POSIX")
        timeParser.timeZone = TimeZone.current
        timeParser.dateFormat = dueTimeString.count == 5 ? "HH:mm" : "HH:mm:ss"

        guard let parsedTime = timeParser.date(from: dueTimeString) else {
            return day
        }

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: parsedTime)
        return calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: day
        ) ?? day
    }

    static func dateString(from date: Date?) -> String? {
        guard let date else { return nil }
        return dateOnlyFormatter.string(from: date)
    }

    static func timeString(from date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    static func habitTimeString(from date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

extension TaskPriority {
    init(supabaseRawValue rawValue: String) {
        self = TaskPriority(rawValue: rawValue.lowercased()) ?? .medium
    }
}
