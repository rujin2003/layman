import SwiftUI
import UIKit

public struct MainTabView: View {
    @ObservedObject var appState: AppState
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var pushNotifications: PushNotificationManager
    @State private var selection = 0

    public var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Image(systemName: selection == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            SavedView()
                .tabItem {
                    Image(systemName: selection == 1 ? "bookmark.fill" : "bookmark")
                    Text("Saved")
                }
                .tag(1)

            ProfileView(appState: appState)
                .tabItem {
                    Image(systemName: selection == 2 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(Theme.Colors.accentOrange)
        .onAppear { applyTabBarAppearance() }
        .onChange(of: colorScheme) { _, _ in applyTabBarAppearance() }
        .onChange(of: appState.appearanceMode) { _, _ in applyTabBarAppearance() }
        .task {
            await pushNotifications.refreshAuthorizationStatus()
            switch pushNotifications.authorizationStatus {
            case .notDetermined:
                await pushNotifications.requestPermissionAndRegister()
            case .authorized, .provisional, .ephemeral:
                pushNotifications.registerForRemoteNotifications()
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    private func applyTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.Colors.creamUIColor

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = Theme.Colors.subtleTextUIColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: Theme.Colors.subtleTextUIColor]
        itemAppearance.selected.iconColor = Theme.Colors.accentOrangeUIColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: Theme.Colors.accentOrangeUIColor]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
