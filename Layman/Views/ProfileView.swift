import SwiftUI
import UIKit

public struct ProfileView: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject private var pushNotifications: PushNotificationManager
    @State private var showLogoutConfirmation = false
    @State private var showSavedArticlesActions = false

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
                            appearanceSection
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
        .task {
            await pushNotifications.refreshAuthorizationStatus()
        }
        .confirmationDialog("Saved articles", isPresented: $showSavedArticlesActions, titleVisibility: .visible) {
            Button("Delete all saved", role: .destructive) {
                Task {
                    await appState.deleteAllSavedArticles()
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("\(appState.savedArticleIDs.count) saved. Delete all removes them from your account.")
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
        .shadow(color: Theme.Colors.cardShadow, radius: 12, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "circle.lefthalf.filled")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.Colors.accentOrange)
                Text("Appearance")
                    .font(Theme.Typography.headline)
                    .foregroundColor(Theme.Colors.darkText)
            }

            Text("Choose light, dark, or match your device.")
                .font(Theme.Typography.caption)
                .foregroundColor(Theme.Colors.subtleText)

            Picker("Appearance", selection: $appState.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appState.appearanceMode) { _, _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: Theme.Colors.cardShadow, radius: 12, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 2) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showSavedArticlesActions = true
            } label: {
                settingsRow(icon: "bookmark.fill", title: "Saved Articles", count: appState.savedArticleIDs.count)
            }
            .buttonStyle(.plain)
            Divider().background(Theme.Colors.hairlineBorder).padding(.horizontal, 20)
            notificationsSettingsRow
            Divider().background(Theme.Colors.hairlineBorder).padding(.horizontal, 20)
            settingsRow(icon: "info.circle.fill", title: "About Layman", subtitle: "v1.0")
        }
        .background(Theme.Colors.cardWhite)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Metrics.cardCornerRadius))
        .shadow(color: Theme.Colors.cardShadow, radius: 12, y: 4)
        .padding(.horizontal, 20)
    }

    private var notificationsSettingsRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            Task { @MainActor in
                await pushNotifications.refreshAuthorizationStatus()
                if pushNotifications.authorizationStatus == .denied {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(url)
                    }
                } else {
                    await pushNotifications.requestPermissionAndRegister()
                }
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.Colors.accentOrange)
                    .frame(width: 32, height: 32)
                    .background(Theme.Colors.accentOrange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Push notifications")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundColor(Theme.Colors.darkText)
                    if let sim = pushNotifications.simulatorPushNote {
                        Text(sim)
                            .font(Theme.Typography.small)
                            .foregroundColor(Theme.Colors.subtleText)
                            .lineLimit(3)
                    }
                    if let err = pushNotifications.lastRegistrationError, !err.isEmpty {
                        Text(err)
                            .font(Theme.Typography.small)
                            .foregroundColor(.red.opacity(0.85))
                            .lineLimit(2)
                    }
                }

                Spacer()

                Text(pushNotifications.statusDescription)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Colors.subtleText)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.Colors.subtleText.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
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
                    .background(Theme.Colors.elevatedSurface)
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
