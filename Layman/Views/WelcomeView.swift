import SwiftUI
import UIKit

public struct WelcomeView: View {
    @ObservedObject var appState: AppState
    @State private var revealProgress: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var sloganOpacity: Double = 0
    @State private var sliderOpacity: Double = 0

    public var body: some View {
        ZStack {
            Theme.Colors.primaryGradient
                .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.06))
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -200)

            Circle()
                .fill(.white.opacity(0.04))
                .frame(width: 300, height: 300)
                .offset(x: 150, y: 300)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 16) {
                    Text("Layman")
                        .font(Theme.Typography.logo)
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    VStack(spacing: 8) {
                        Text("Business, tech & startups")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Text("made simple")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.2))
                            )
                    }
                    .opacity(sloganOpacity)
                }

                Spacer()

                VStack(spacing: 20) {
                    SwipeToStartSlider {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.4)) {
                            appState.currentScreen = .auth
                        }
                    }
                    .padding(.horizontal, 32)

                    Text("Swipe to explore")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(sliderOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                sloganOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                sliderOpacity = 1.0
            }
        }
    }
}
