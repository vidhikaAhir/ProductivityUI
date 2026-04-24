import Foundation
import Combine
import UIKit
import CryptoKit

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?

    private let session: AppSession

    init(session: AppSession = .shared) {
        self.session = session
    }

    func loginUser(phone: String, password: String) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            let hashedPassword = hashPassword(password)
            let user = try await UserRowData.shared.fetchSingleUser(id: phone, password: hashedPassword)
            session.setUserID(user.id)
        } catch {
            errorMessage = "Mobile number or password is incorrect."
        }
    }

    func createUser(
        username: String,
        email: String,
        phone: String,
        password: String,
        image: UIImage
    ) async {
        isProcessing = true
        errorMessage = nil
        defer { isProcessing = false }

        do {
            _ = try await UserRowData.shared.fetchSingleUser(id: phone)
            errorMessage = "An account already exists for this mobile number."
            return
        } catch {
            // No matching account yet, continue with sign up.
        }

        do {
            let imageURL = try await UserRowData.shared.uploadImage(image)
            let hashedPassword = hashPassword(password)
            try await UserRowData.shared.addUser(
                id: phone,
                username: username,
                email: email,
                phone: phone,
                password: hashedPassword,
                imageURL: imageURL
            )
            session.setUserID(phone)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func hashPassword(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
