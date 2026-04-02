import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications

final class LaymanAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        Task { @MainActor in
            await PushNotificationManager.shared.refreshAuthorizationStatus()
            if PushNotificationManager.shared.authorizationStatus == .authorized
                || PushNotificationManager.shared.authorizationStatus == .provisional
                || PushNotificationManager.shared.authorizationStatus == .ephemeral {
                PushNotificationManager.shared.registerForRemoteNotifications()
            }
        }

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Task { @MainActor in
            PushNotificationManager.shared.reportRegistrationError(error.localizedDescription)
        }
    }
}

extension LaymanAppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in
            PushNotificationManager.shared.updateFCMToken(fcmToken)
            PushNotificationManager.shared.reportRegistrationError(nil)
        }
        NotificationCenter.default.post(name: .fcmTokenDidRefresh, object: fcmToken)
    }
}

extension LaymanAppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
