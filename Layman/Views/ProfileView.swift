import SwiftUI
import UIKit

public struct ProfileView: View {
    @ObservedObject var appState: AppState
    @State private var showLogoutConfirmation = false

    private var userEmail: String {
        SupabaseService.shared.userEmail
    }

    private var userName: String {
        let email = userEmail
        if let atIndex = email.firstIndex(of: "@") {
            return String(email[..<atIndex]).capitalized
        }
        return "User"
    }

    private var userInitial: String {
        String(userName.prefix(1)).uppercased()
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.cream.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("Profile")
                            .font(Theme.Typography.title1)
                            .foregroundColor(Theme.Colors.darkText)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            userInfoCard
                            settingsSection
                            Spacer(minLength: 40)
                            logoutButton
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                Task { await appState.logout() }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - User Info Card

    private var userInfoCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.buttonGradient)
                    .frame(width: 72, height: 72)
                Text(userInitial)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(userName)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.darkText)

                Text(userEmail)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.Colors.subtleText)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 2) {
            settingsRow(icon: "bookmark.fill", title: "Saved Articles", count: appState.savedArticleIDs.count)
            Divider().padding(.horizontal, 20)
            settingsRow(icon: "bell.fill", title: "Notifications", subtitle: "Coming soon")
            Divider().padding(.horizontal, 20)
            settingsRow(icon: "paintbrush.fill", title: "Appearance", subtitle: "Light")
            Divider().padding(.horizontal, 20)
            settingsRow(icon: "info.circle.fill", title: "About Layman", subtitle: "v1.0")
        }
        .background(Theme.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 4)
        .padding(.horizontal, 20)
    }

    private func settingsRow(icon: String, title: String, subtitle: String? = nil, count: Int? = nil) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.Colors.accentOrange)
                .frame(width: 32, height: 32)
                .background(Theme.Colors.accentOrange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.darkText)

            Spacer()

            if let count = count {
                Text("\(count)")
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.subtleText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.beige)
                    .clipShape(Capsule())
            } else if let subtitle = subtitle {
                Text(subtitle)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.subtleText)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Theme.Colors.subtleText.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            showLogoutConfirmation = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                Text("Sign Out")
                    .font(Theme.Typography.headline)
            }
            .foregroundColor(.red.opacity(0.8))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(.red.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Metrics.largeCornerRadius)
                    .stroke(.red.opacity(0.15), lineWidth: 1)
            )
        }
        .padding(.horizontal, 20)
    }
}
