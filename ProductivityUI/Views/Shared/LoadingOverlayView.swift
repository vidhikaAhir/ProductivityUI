import SwiftUI

struct LoadingOverlayView: View {
    let title: String

    init(_ title: String = "Loading...") {
        self.title = title
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.16)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(AppTheme.accent)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(RoundedRectangle(cornerRadius: 16).fill(AppTheme.card))
            .shadow(radius: 18, y: 8)
        }
    }
}
