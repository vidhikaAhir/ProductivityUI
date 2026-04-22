import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserRow?

    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
        Task { await loadData() }
    }

    func refresh() {
        Task { await loadData() }
    }

    func loadData() async {
        do {
            profile = try await profileService.fetchProfile()
        } catch {
            print("Failed to fetch profile: \(error)")
        }
    }

    func updateProfile(_ profile: UserRow) {
        Task {
            do {
                try await profileService.updateProfile(profile)
                await loadData()
            } catch {
                print("Failed to update profile: \(error)")
            }
        }
    }
}
