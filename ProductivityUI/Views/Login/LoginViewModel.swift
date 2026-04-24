import Foundation
import Combine
import UIKit

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isCreatingAccount = false
    @Published var errorMessage: String?

    private let session: AppSession

    init(session: AppSession = .shared) {
        self.session = session
    }

    func createUser(
        username: String,
        email: String,
        phone: String,
        image: UIImage
    ) async {
        isCreatingAccount = true
        errorMessage = nil
        defer { isCreatingAccount = false }

        do {
            let imageURL = try await UserRowData.shared.uploadImage(image)
            try await UserRowData.shared.addUser(
                id: phone,
                username: username,
                email: email,
                phone: phone,
                imageURL: imageURL
            )
            session.setUserID(phone)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
