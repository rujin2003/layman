import SwiftUI
import UIKit

public struct SwipeToStartSlider: View {
    let action: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted = false

    private let trackHeight: CGFloat = 64
    private let thumbSize: CGFloat = 56
    private let horizontalPadding: CGFloat = 4

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let maxDrag = trackWidth - thumbSize - (horizontalPadding * 2)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    )

                Text("Swipe to get started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, thumbSize)
                    .opacity(Double(max(0, 1 - (dragOffset / maxDrag * 1.5))))

                ZStack {
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.15), radius: 6, y: 3)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Theme.Colors.accentOrange)
                }
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: dragOffset + horizontalPadding)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard !isCompleted else { return }
                            let t = value.translation.width
                            dragOffset = min(max(0, t), maxDrag)
                        }
                        .onEnded { _ in
                            guard !isCompleted else { return }
                            if dragOffset >= maxDrag * 0.8 {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    dragOffset = maxDrag
                                    isCompleted = true
                                }
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    action()
                                }
                            } else {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    dragOffset = 0
                                }
                            }
                        }
                )
            }
            .frame(height: trackHeight)
        }
        .frame(height: trackHeight)
    }
}
