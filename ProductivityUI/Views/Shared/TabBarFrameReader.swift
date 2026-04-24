import SwiftUI
import UIKit

struct TabBarFrameReader: UIViewRepresentable {
    var onChange: ([OnboardingTarget: CGRect]) -> Void

    func makeUIView(context: Context) -> ReaderView {
        ReaderView(onChange: onChange)
    }

    func updateUIView(_ uiView: ReaderView, context: Context) {
        uiView.onChange = onChange
        uiView.refreshFrames()
    }

    final class ReaderView: UIView {
        var onChange: ([OnboardingTarget: CGRect]) -> Void
        private var lastFrames: [OnboardingTarget: CGRect] = [:]

        init(onChange: @escaping ([OnboardingTarget: CGRect]) -> Void) {
            self.onChange = onChange
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            backgroundColor = .clear
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMoveToWindow() {
            super.didMoveToWindow()
            refreshFrames()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            refreshFrames()
        }

        func refreshFrames() {
            DispatchQueue.main.async { [weak self] in
                self?.captureFrames()
            }
        }

        private func captureFrames() {
            guard let tabBar = window?.findSubview(of: UITabBar.self) else { return }
            let targetView = window?.rootViewController?.view ?? self

            let buttons = tabBar.subviews
                .filter { String(describing: type(of: $0)).contains("UITabBarButton") }
                .sorted { $0.frame.minX < $1.frame.minX }

            let orderedTargets: [OnboardingTarget] = [
                .calendarTab,
                .tasksTab,
                .notesTab,
                .habitsTab,
                .profileTab
            ]

            var frames: [OnboardingTarget: CGRect] = [:]
            for (index, button) in buttons.enumerated() where index < orderedTargets.count {
                frames[orderedTargets[index]] = button.convert(button.bounds, to: targetView)
            }

            guard frames != lastFrames else { return }
            lastFrames = frames
            onChange(frames)
        }
    }
}

private extension UIView {
    func findSubview<T: UIView>(of type: T.Type) -> T? {
        if let match = self as? T {
            return match
        }

        for subview in subviews {
            if let match = subview.findSubview(of: type) {
                return match
            }
        }

        return nil
    }
}
