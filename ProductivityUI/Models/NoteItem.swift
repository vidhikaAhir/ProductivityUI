import Foundation

struct NoteItem: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var body: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        body: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(from row: NoteModel) {
        self.id = UUID(uuidString: row.id) ?? UUID()
        self.title = row.title
        self.body = row.content ?? row.subtitle ?? ""
        let createdAt = SupabaseDateTransform.parseDate(row.created_at) ?? Date()
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
