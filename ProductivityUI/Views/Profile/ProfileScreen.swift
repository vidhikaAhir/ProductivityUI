import SwiftUI

struct ProfileScreen: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingLogoutConfirmation = false

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        profileAvatar
                            .frame(width: 52, height: 52)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.profile?.username ?? "Your profile")
                                .font(.title3.bold())
                            Text(viewModel.profile?.email ?? "Loading...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))

                    VStack(spacing: 0) {
                        profileRow(icon: "person", title: "Username", value: viewModel.profile?.username ?? "—")
                        Divider().padding(.leading, 44)
                        profileRow(icon: "envelope", title: "Email", value: viewModel.profile?.email ?? "—")
                        if let phone = viewModel.profile?.phone, phone.isEmpty == false {
                            Divider().padding(.leading, 44)
                            profileRow(icon: "phone", title: "Phone", value: phone)
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))

                    Button(role: .destructive) {
                        showingLogoutConfirmation = true
                    } label: {
                        Text("Log Out")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.red))
                    }
                    .padding(.top, 6)
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .refreshable {
                viewModel.refresh()
            }
            .overlay {
                if viewModel.isLoading {
                    LoadingOverlayView("Updating profile...")
                }
            }
        }
        .onAppear {
            viewModel.refresh()
        }
        .alert("Log Out", isPresented: $showingLogoutConfirmation) {
            Button("Log Out", role: .destructive) {
                AppSession.shared.clearUserID()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll need to sign in again to access your workspace.")
        }
    }

    private var profileAvatar: some View {
        Group {
            if let imageURL = viewModel.profile?.avatarImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 52, height: 52)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    case .failure:
                        fallbackAvatar
                    @unknown default:
                        fallbackAvatar
                    }
                }
            } else {
                fallbackAvatar
            }
        }
    }

    private var fallbackAvatar: some View {
        Image(systemName: "person.crop.circle.fill")
            .font(.system(size: 52))
            .foregroundColor(AppTheme.accent)
    }

    private func profileRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppTheme.accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding()
    }
}
