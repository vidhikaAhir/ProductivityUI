import SwiftUI

extension OnboardingTarget: Hashable {}

struct SpotlightFramePreferenceKey: PreferenceKey {
    static var defaultValue: [OnboardingTarget: CGRect] = [:]

    static func reduce(value: inout [OnboardingTarget: CGRect], nextValue: () -> [OnboardingTarget: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    func spotlightFrame(target: OnboardingTarget) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: SpotlightFramePreferenceKey.self,
                    value: [target: proxy.frame(in: .global)]
                )
            }
        )
    }
}
