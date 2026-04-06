import Flutter
import UIKit
import Firebase
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        GeneratedPluginRegistrant.register(with: registry)
      }
      
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }  
    GeneratedPluginRegistrant.register(with: self)
    // Set navigation bar (home indicator area) to white
    if #available(iOS 15.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = UIColor.white
      UINavigationBar.appearance().standardAppearance = appearance
      UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
