import SwiftUI

public struct WelcomeView: View {
    @ObservedObject var appState: AppState
    @State private var revealProgress: Double = 0
    @State private var highlightPulse = false
    @State private var arrowBounce = false
    
    public var body: some View {
        ZStack {
            Theme.Colors.primaryGradient
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo
                Text("Layman")
                    .font(Theme.Typography.logo)
                    .foregroundColor(Theme.Colors.darkText)
                    .padding(.bottom, 8)
                
                // Slogan
                VStack(spacing: 8) {
                    AnimatedRevealText(
                        text: "Business, tech & startups",
                        progress: revealProgress
                    )
                    .font(Theme.Typography.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Theme.Colors.darkText)
                    .opacity(0.95)
                    .padding(.horizontal, 32)
                    
                    Text("made simple")
                        .font(Theme.Typography.title3.weight(.bold))
                        .foregroundColor(Theme.Colors.accentOrange)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Theme.Colors.accentOrange.opacity(0.18))
                                .blur(radius: highlightPulse ? 18 : 12)
                                .scaleEffect(highlightPulse ? 1.05 : 0.95)
                        )
                        .shadow(color: Theme.Colors.accentOrange.opacity(0.25), radius: 10, y: 4)
                }
                
                Spacer()
                
                // Swipe to Start
                SwipeToStartSlider {
                    // Action when completed
                    appState.currentScreen = .auth
                }
                .padding(.horizontal, Theme.Metrics.padding * 2)
                .padding(.bottom, 60)
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    )
                    .offset(x: arrowBounce ? 10 : -2)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: arrowBounce)
                    .onAppear {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        withAnimation(.easeInOut(duration: 1.8)) {
                            revealProgress = 1
                        }
                        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.4)) {
                            highlightPulse.toggle()
                        }
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                            arrowBounce.toggle()
                        }
                    }
            }
        }
    }
}

struct AnimatedRevealText: View {
    let text: String
    let progress: Double
    
    var body: some View {
        Text(text)
            .foregroundColor(Theme.Colors.darkText.opacity(0.25))
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    let width = geo.size.width * progress
                    Text(text)
                        .foregroundColor(Theme.Colors.darkText)
                        .mask(
                            Rectangle()
                                .frame(width: width)
                                .alignmentGuide(.leading) { d in d[.leading] }
                        )
                }
            }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(appState: AppState())
    }
}
