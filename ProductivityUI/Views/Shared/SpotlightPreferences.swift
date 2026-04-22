import SwiftUI

enum SpotlightFrameTarget: Hashable {
    case addButton
}

struct SpotlightFramePreferenceKey: PreferenceKey {
    static var defaultValue: [SpotlightFrameTarget: CGRect] = [:]

    static func reduce(value: inout [SpotlightFrameTarget: CGRect], nextValue: () -> [SpotlightFrameTarget: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

extension View {
    func spotlightFrame(target: SpotlightFrameTarget) -> some View {
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
