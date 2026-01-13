import UIKit
import Flutter
import Firebase
import GoogleMaps


@main
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //let key: String = "AIzaSyCsXI6iK1Dbf7ZtJI6NHNv74Hv_CXP-428"//FlutterConfigPlugin.env(for: "IOS_MAPS_APIKEY")
    if #available(iOS 10.0, *) { 
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()
        
    }
      
    GMSServices.provideAPIKey("AIzaSyCsXI6iK1Dbf7ZtJI6NHNv74Hv_CXP-428")
    FirebaseApp.configure()
      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
}
