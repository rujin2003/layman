import Combine
import SwiftUI
import UserNotifications
import UIKit

extension Notification.Name {
    static let fcmTokenDidRefresh = Notification.Name("layman.fcmTokenDidRefresh")
}

@MainActor
final class PushNotificationManager: ObservableObject {
    static let shared = PushNotificationManager()
    static let fcmTokenDefaultsKey = "layman_fcm_token"

    @Published private(set) var fcmToken: String?
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var lastRegistrationError: String?

    private init() {
        fcmToken = UserDefaults.standard.string(forKey: Self.fcmTokenDefaultsKey)
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    /// Call after permission grant or from Profile to (re)register with APNs.
    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func requestPermissionAndRegister() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            lastRegistrationError = nil
            if granted {
                registerForRemoteNotifications()
            }
        } catch {
            lastRegistrationError = error.localizedDescription
            await refreshAuthorizationStatus()
        }
    }

    func updateFCMToken(_ token: String?) {
        fcmToken = token
        if let token {
            UserDefaults.standard.set(token, forKey: Self.fcmTokenDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.fcmTokenDefaultsKey)
        }
    }

    func reportRegistrationError(_ message: String?) {
        lastRegistrationError = message
    }

    var statusDescription: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral: return "On"
        case .denied: return "Off"
        case .notDetermined: return "Not set"
        @unknown default: return "Unknown"
        }
    }

    /// Remote push delivery is unreliable on Simulator; use a real device to verify FCM/APNs.
    var simulatorPushNote: String? {
        #if targetEnvironment(simulator)
        return "Simulator cannot receive remote push. Use a physical iPhone to test notifications."
        #else
        return nil
        #endif
    }
}
