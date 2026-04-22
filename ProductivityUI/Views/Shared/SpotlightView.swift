import SwiftUI

struct SpotlightView: View {
    let rect: CGRect
    let title: String
    let message: String
    let stepText: String
    let canGoBack: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Color.black.opacity(0.65)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .frame(width: max(rect.width + 16, 50), height: max(rect.height + 16, 50))
                            .position(x: rect.midX, y: rect.midY)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()
                    .ignoresSafeArea()
                    .onTapGesture { }

                tooltip(in: proxy.size)
            }
            .animation(.easeInOut(duration: 0.25), value: rect)
        }
        .allowsHitTesting(true)
    }

    private func tooltip(in containerSize: CGSize) -> some View {
        let spacing: CGFloat = 20
        let cardWidth = min(containerSize.width - 32, 320)
        let isBelow = rect.maxY + 190 < containerSize.height
        let y = isBelow
            ? min(rect.maxY + spacing, containerSize.height - 180)
            : max(rect.minY - 180, 30)
        let x = min(max(rect.midX - (cardWidth / 2), 16), containerSize.width - cardWidth - 16)

        return VStack(alignment: .leading, spacing: 12) {
            Text(stepText)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Button("Skip", action: onSkip)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)

                Spacer()

                Button("Back", action: onBack)
                    .font(.subheadline.weight(.semibold))
                    .disabled(!canGoBack)
                    .opacity(canGoBack ? 1 : 0.4)

                Button("Next", action: onNext)
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(AppTheme.accent))
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .frame(width: cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.05))
        )
        .position(x: x + cardWidth / 2, y: y + 80)
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
}
