import Foundation

struct AppNotificationItem: Identifiable, Equatable, Codable {
    let id: UUID
    let relatedTaskID: UUID?
    var title: String
    var message: String
    var createdAt: Date
    var isViewed: Bool

    init(
        id: UUID = UUID(),
        relatedTaskID: UUID? = nil,
        title: String,
        message: String,
        createdAt: Date = Date(),
        isViewed: Bool = false
    ) {
        self.id = id
        self.relatedTaskID = relatedTaskID
        self.title = title
        self.message = message
        self.createdAt = createdAt
        self.isViewed = isViewed
    }
}
