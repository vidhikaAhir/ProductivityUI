import Foundation
import Combine

enum AppSessionError: LocalizedError {
    case missingUserSession

    var errorDescription: String? {
        "No user session is available."
    }
}

@MainActor
final class AppSession: ObservableObject {
    static let shared = AppSession()

    @Published private(set) var currentUserID: String?

    private init() {
        currentUserID = UserDefaults.standard.string(forKey: "user_id")
    }

    func setUserID(_ userID: String) {
        currentUserID = userID
        UserDefaults.standard.set(userID, forKey: "user_id")
    }

    func clearUserID() {
        currentUserID = nil
        UserDefaults.standard.removeObject(forKey: "user_id")
    }

    var isLoggedIn: Bool {
        currentUserID != nil
    }
}
