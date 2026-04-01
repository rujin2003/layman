import SwiftUI
import UIKit
import CoreHaptics

public struct SwipeToStartSlider: View {
    let action: () -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    
    // Constants
    private let trackHeight: CGFloat = 64
    private let thumbSize: CGFloat = 56
    private let horizontalPadding: CGFloat = 4
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let maxDragLength = trackWidth - thumbSize - (horizontalPadding * 2)
            
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.white.opacity(0.2)) // Glassmorphism look
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                // Track Text
                Text("Swipe to get started")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.leading, thumbSize)
                    .opacity(Double(max(0, 1 - (dragOffset / maxDragLength * 1.5))))
                
                // Overlay to show progress optionally, or just the thumb sliding
                
                // Swipe Thumb
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Theme.Colors.accentOrange)
                }
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: dragOffset + horizontalPadding)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isCompleted { return }
                            let translation = value.translation.width
                            if translation > 0 && translation <= maxDragLength {
                                dragOffset = translation
                            } else if translation > maxDragLength {
                                dragOffset = maxDragLength
                            } else if translation < 0 {
                                dragOffset = 0
                            }
                        }
                        .onEnded { value in
                            if isCompleted { return }
                            if dragOffset >= maxDragLength * 0.85 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    dragOffset = maxDragLength
                                    isCompleted = true
                                }
                                triggerHaptic()
                                // Small delay to feel the thud before navigation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}
