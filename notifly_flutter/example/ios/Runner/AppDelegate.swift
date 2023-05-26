import Flutter
import notifly_sdk
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
//        Notifly.initialize(projectID: "b80c3f0e2fbd5eb986df4f1d32ea2871", username: "minyong", password: "000000")
        /* Required */
        UNUserNotificationCenter.current().delegate = self
        // UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        //     DispatchQueue.main.async {
        //         UIApplication.shared.registerForRemoteNotifications()
        //     }
        // }
        /* Required */

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        /* Required */
        Notifly.application(application,
                            didFailToRegisterForRemoteNotificationsWithError: error)
        super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
        /* Required */
    }

    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        /* Required */
        Notifly.application(application,
                            didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        /* Required */
    }

    override func application(_ application: UIApplication,
                              didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        /* Required */
        Notifly.application(application,
                            didReceiveRemoteNotification: userInfo,
                            fetchCompletionHandler: completionHandler)
        super.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
        /* Required */
    }
//
    override func userNotificationCenter(_ notificationCenter: UNUserNotificationCenter,
                                         didReceive response: UNNotificationResponse,
                                         withCompletionHandler completion: @escaping () -> Void)
    {
        /* Required */
        Notifly.userNotificationCenter(notificationCenter,
                                       didReceive: response,
                                       withCompletionHandler: completion)
        super.userNotificationCenter(notificationCenter, didReceive: response, withCompletionHandler: completion)
        /* Required */
    }

    override func userNotificationCenter(_ notificationCenter: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completion: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        /* Required */
        Notifly.userNotificationCenter(notificationCenter,
                                       willPresent: notification,
                                       withCompletionHandler: completion)
        /* Required */
        super.userNotificationCenter(notificationCenter, willPresent: notification, withCompletionHandler: completion)
    }
}
