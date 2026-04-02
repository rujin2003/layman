import SwiftUI

@main
struct LaymanApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isCheckingSession {
                    SplashView()
                } else {
                    switch appState.currentScreen {
                    case .welcome:
                        WelcomeView(appState: appState)
                            .transition(.opacity)
                    case .auth:
                        AuthView(appState: appState)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    case .main:
                        MainTabView(appState: appState)
                            .transition(.opacity)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appState.currentScreen)
            .environmentObject(appState)
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.Colors.primaryGradient
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("Layman")
                    .font(Theme.Typography.logo)
                    .foregroundColor(.white)

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.1)
            }
        }
    }
}
