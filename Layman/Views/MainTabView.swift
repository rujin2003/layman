import SwiftUI
import UIKit

public struct MainTabView: View {
    @ObservedObject var appState: AppState
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
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.Colors.cream)

            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor(Theme.Colors.subtleText)
            itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.subtleText)]
            itemAppearance.selected.iconColor = UIColor(Theme.Colors.accentOrange)
            itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Theme.Colors.accentOrange)]

            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance

            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
