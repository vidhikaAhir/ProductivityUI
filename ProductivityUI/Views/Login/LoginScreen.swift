import SwiftUI
import PhotosUI
import UIKit

struct LoginScreen: View {
    @State private var isSignupMode = false
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""
    @State private var loginPhone: String = ""
    @State private var loginPassword: String = ""
    @State private var image: Image? = nil
    @State private var selectedUIImage: UIImage? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var focusedField: LoginField?

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                ScrollView {
                    VStack(spacing: 30) {
                        HeaderView()
                        loginCard
                    }
                    .padding(.vertical, 32)
                }
            }
            .alert("Login Failed", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Something went wrong.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
    }

    private var isSignupValid: Bool {
        hasContent(username) && isValidEmail(email) && isValidPhone(phone) && isValidPassword(password) && image != nil
    }

    private var isLoginValid: Bool {
        isValidPhone(loginPhone) && isValidPassword(loginPassword)
    }

    private var loginCard: some View {
        Card {
            VStack(spacing: 16) {
                modeToggle

                Group {
                    if isSignupMode {
                        signupSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    } else {
                        loginSection
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .padding(20)
        }
        .padding(.horizontal)
    }

    private var modeToggle: some View {
        HStack(spacing: 12) {
            toggleButton(title: "Login", isSelected: !isSignupMode) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSignupMode = false
                }
            }

            toggleButton(title: "Signup", isSelected: isSignupMode) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSignupMode = true
                }
            }
        }
        .padding(.top, 4)
    }

    private var loginSection: some View {
        VStack(spacing: 12) {
            StyledTextField(
                title: "Mobile number",
                text: $loginPhone,
                keyboard: .numberPad,
                systemImage: "phone",
                submitLabel: .next,
                focusedField: $focusedField,
                field: .loginPhone,
                contentType: .telephoneNumber,
                validationMessage: loginPhoneValidationMessage
            )
            StyledTextField(
                title: "Password",
                text: $loginPassword,
                systemImage: "lock",
                submitLabel: .done,
                focusedField: $focusedField,
                field: .loginPassword,
                contentType: .password, isSecure: true,
                validationMessage: loginPasswordValidationMessage
            )

            Button(action: login) {
                ZStack {
                    Text("Log In")
                        .opacity(viewModel.isProcessing ? 0 : 1)
                    if viewModel.isProcessing {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.accent.opacity(0.85))
                )
            }
            .buttonStyle(.plain)
            .disabled(!isLoginValid || viewModel.isProcessing)
            .opacity(isLoginValid ? 1 : 0.6)
        }
    }

    private var signupSection: some View {
        VStack(spacing: 12) {
            UploadAvatar(image: $image, selectedItem: $selectedItem)
                .padding(.bottom, 8)
                .onChange(of: selectedItem, perform: loadSelectedImage)

            StyledTextField(
                title: "Username",
                text: $username,
                systemImage: "person",
                submitLabel: .next,
                focusedField: $focusedField,
                field: .signupUsername
            )
            StyledTextField(
                title: "Email address",
                text: $email,
                keyboard: .emailAddress,
                systemImage: "envelope",
                submitLabel: .next,
                focusedField: $focusedField,
                field: .signupEmail,
                contentType: .emailAddress,
                validationMessage: emailValidationMessage
            )
            StyledTextField(
                title: "Phone number",
                text: $phone,
                keyboard: .numberPad,
                systemImage: "phone",
                submitLabel: .next,
                focusedField: $focusedField,
                field: .signupPhone,
                contentType: .telephoneNumber,
                validationMessage: phoneValidationMessage
            )
            StyledTextField(
                title: "Password",
                text: $password,
                systemImage: "lock",
                submitLabel: .done,
                focusedField: $focusedField,
                field: .signupPassword,
                contentType: .newPassword,
                isSecure: true,
                validationMessage: signupPasswordValidationMessage
            )

            Button(action: signup) {
                ZStack {
                    Text("Sign Up")
                        .opacity(viewModel.isProcessing ? 0 : 1)
                    if viewModel.isProcessing {
                        ProgressView()
                            .tint(AppTheme.accent)
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .foregroundStyle(AppTheme.accent)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.accent.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(AppTheme.accent.opacity(0.25))
                )
            }
            .buttonStyle(.plain)
            .disabled(!isSignupValid || viewModel.isProcessing)
            .opacity(isSignupValid ? 1 : 0.6)
            .padding(.top, 4)

            Button("Already have an account?") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSignupMode = false
                }
            }
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .buttonStyle(.plain)
        }
    }

    private func login() {
        focusedField = nil
        let normalizedPhone = loginPhone.filter(\.isNumber)

        guard isValidPhone(normalizedPhone) else {
            viewModel.errorMessage = "Please enter a valid mobile number."
            return
        }
        guard isValidPassword(loginPassword) else {
            viewModel.errorMessage = "Please enter a valid password."
            return
        }
        Task {
            await viewModel.loginUser(phone: normalizedPhone, password: loginPassword)
        }
    }

    private func signup() {
        focusedField = nil
        guard let img = selectedUIImage else { return }
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedPhone = phone.filter(\.isNumber)

        guard hasContent(normalizedUsername) else {
            viewModel.errorMessage = "Please enter a username."
            return
        }
        guard isValidEmail(normalizedEmail) else {
            viewModel.errorMessage = "Please enter a valid email address."
            return
        }
        guard isValidPhone(normalizedPhone) else {
            viewModel.errorMessage = "Please enter a valid mobile number."
            return
        }
        guard isValidPassword(password) else {
            viewModel.errorMessage = "Password must be at least 6 characters."
            return
        }
        Task {
            await viewModel.createUser(username: normalizedUsername, email: normalizedEmail, phone: normalizedPhone, password: password, image: img)
        }
    }

    private func loadSelectedImage(_ newValue: PhotosPickerItem?) {
        Task {
            guard
                let data = try? await newValue?.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: data)
            else { return }

            selectedUIImage = uiImage
            image = Image(uiImage: uiImage)
        }
    }

    private func hasContent(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var emailValidationMessage: String? {
        guard hasContent(email) else { return nil }
        return isValidEmail(email) ? nil : "Enter a valid email address."
    }

    private var phoneValidationMessage: String? {
        guard hasContent(phone) else { return nil }
        return isValidPhone(phone) ? nil : "Enter a valid mobile number."
    }

    private var signupPasswordValidationMessage: String? {
        guard hasContent(password) else { return nil }
        return isValidPassword(password) ? nil : "Password must be at least 6 characters."
    }

    private var loginPhoneValidationMessage: String? {
        guard hasContent(loginPhone) else { return nil }
        return isValidPhone(loginPhone) ? nil : "Enter a valid mobile number."
    }

    private var loginPasswordValidationMessage: String? {
        guard hasContent(loginPassword) else { return nil }
        return isValidPassword(loginPassword) ? nil : "Password must be at least 6 characters."
    }

    private func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return false }
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private func isValidPhone(_ value: String) -> Bool {
        let digits = value.filter(\.isNumber)
        return digits.count == 10
    }

    private func isValidPassword(_ value: String) -> Bool {
        value.count >= 6 && value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func toggleButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? .white : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isSelected ? AppTheme.accent : Color.secondary.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
    }
}

fileprivate enum LoginField {
    case loginPhone
    case loginPassword
    case signupUsername
    case signupEmail
    case signupPhone
    case signupPassword
}

// MARK: - Components

private struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay {
            DotsPattern()
                .foregroundStyle(.secondary.opacity(0.15))
                .allowsHitTesting(false)
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(AppTheme.accent)
                Text("ProductivityUI")
                    .font(.title).fontWeight(.semibold)
                    .foregroundStyle(AppTheme.accent)
            }
            Text("Log in to continue to your workspace")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 12)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.black.opacity(0.06))
            content
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct UploadAvatar: View {
    @Binding var image: Image?
    @Binding var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 88, height: 88)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.black.opacity(0.08))
                    )

                Group {
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Upload")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

private struct StyledTextField: View {
    var title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var systemImage: String? = nil
    var submitLabel: SubmitLabel = .done
    var focusedField: FocusState<LoginField?>.Binding? = nil
    var field: LoginField? = nil
    var contentType: UITextContentType? = nil
    var isSecure: Bool = false
    var validationMessage: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.primary)
            HStack(spacing: 10) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .foregroundStyle(.primary)
                }
                fieldView
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.06))
            )

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var fieldView: some View {
        if let focusedField, let field {
            editor
                .focused(focusedField, equals: field)
        } else {
            editor
        }
    }

    @ViewBuilder
    private var editor: some View {
        if isSecure {
            SecureField("", text: $text)
                .keyboardType(keyboard)
                .submitLabel(submitLabel)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(contentType)
                .onChange(of: text) { newValue in
                    if keyboard == .numberPad {
                        text = String(newValue.filter(\.isNumber).prefix(10))
                    }
                }
        } else {
            TextField("", text: $text)
                .keyboardType(keyboard)
                .submitLabel(submitLabel)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .textContentType(contentType)
                .onChange(of: text) { newValue in
                    if keyboard == .numberPad {
                        text = String(newValue.filter(\.isNumber).prefix(10))
                    }
                }
        }
    }
}

private struct DotsPattern: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            Canvas { context, _ in
                let spacing: CGFloat = 16
                let dot = Path(ellipseIn: CGRect(x: 0, y: 0, width: 2, height: 2))
                let rows = Int(ceil(size.height / spacing))
                let cols = Int(ceil(size.width / spacing))
                for row in 0...rows {
                    for col in 0...cols {
                        var transform = CGAffineTransform(translationX: CGFloat(col) * spacing, y: CGFloat(row) * spacing)
                        let cgPath = dot.cgPath

                        if let p = cgPath.copy(using: &transform) {
                            context.stroke(Path(p), with: .color(AppTheme.accent.opacity(0.2)))
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
