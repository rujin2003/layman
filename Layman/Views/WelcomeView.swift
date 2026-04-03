import SwiftUI
import UIKit

public struct WelcomeView: View {
    @ObservedObject var appState: AppState
    @State private var logoScale: CGFloat = 0.82
    @State private var logoOpacity: Double = 0
    @State private var sloganOpacity: Double = 0
    @State private var sliderOpacity: Double = 0
    @State private var driftPhase = false
    @State private var accentPulse = false
    @State private var shimmer = false

    public var body: some View {
        ZStack {
            Theme.Colors.primaryGradient
                .ignoresSafeArea()

            Circle()
                .fill(.white.opacity(0.07))
                .frame(width: 400, height: 400)
                .offset(x: driftPhase ? -80 : -120, y: driftPhase ? -190 : -210)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: driftPhase)

            Circle()
                .fill(.white.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: driftPhase ? 160 : 140, y: driftPhase ? 290 : 310)
                .animation(.easeInOut(duration: 4.2).repeatForever(autoreverses: true), value: driftPhase)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 18) {
                    Text("Layman")
                        .font(Theme.Typography.logo)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)

                    VStack(spacing: 10) {
                        Text("Business, tech & startups")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.92))
                            .offset(x: shimmer ? 2 : -2)
                            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: shimmer)

                        Text("made simple")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(accentPulse ? 0.26 : 0.18))
                            )
                            .scaleEffect(accentPulse ? 1.03 : 1.0)
                            .shadow(color: .white.opacity(0.25), radius: accentPulse ? 14 : 8, y: 4)
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
                        .foregroundColor(.white.opacity(0.65))
                }
                .opacity(sliderOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            driftPhase = true
            shimmer = true
            withAnimation(.easeOut(duration: 0.75)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.55).delay(0.25)) {
                sloganOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.55).delay(0.5)) {
                sliderOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.8)) {
                accentPulse = true
            }
        }
    }
}
