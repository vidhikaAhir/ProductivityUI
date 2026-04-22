import Foundation

struct HabitItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var expTime: String
    var completedDates: Set<DateKey>
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        detail: String = "",
        expTime: String = "",
        completedDates: Set<DateKey> = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.expTime = expTime
        self.completedDates = completedDates
        self.createdAt = createdAt
    }

    init(from row: HabitModel, logs: [HabitLogModel] = []) {
        self.id = UUID(uuidString: row.id) ?? UUID()
        self.title = row.title
        self.detail = row.duration
        self.expTime = row.exp_time ?? ""
        self.completedDates = Set(
            logs.compactMap { log in
                guard log.completed, let date = log.dateValue else { return nil }
                return DateKey(date: date)
            }
        )
        self.createdAt = row.createdAtValue ?? Date()
    }

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(DateKey(date: date))
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.detail = try container.decodeIfPresent(String.self, forKey: .detail) ?? ""
        self.expTime = try container.decodeIfPresent(String.self, forKey: .expTime) ?? ""
        self.completedDates = []
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(detail, forKey: .detail)
        try container.encode(expTime, forKey: .expTime)
        try container.encode(createdAt, forKey: .createdAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case detail
        case expTime = "exp_time"
        case createdAt = "created_at"
    }
}

struct DateKey: Hashable, Sendable, Codable {
    let year: Int
    let month: Int
    let day: Int

    init(date: Date, calendar: Calendar = .current) {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        self.year = components.year ?? 0
        self.month = components.month ?? 0
        self.day = components.day ?? 0
    }
}
