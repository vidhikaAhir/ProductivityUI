import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile() async throws -> UserRow
    func updateProfile(_ profile: UserRow) async throws
}

final class SupabaseProfileService: ProfileServiceProtocol {
    init() {}

    func fetchProfile() async throws -> UserRow {
        try await UserRowData.shared.activeUser()
    }

    func updateProfile(_ profile: UserRow) async throws {
        try await UserRowData.shared.updateUser(
            id: profile.id,
            username: profile.username ?? ""
        )
    }
}
