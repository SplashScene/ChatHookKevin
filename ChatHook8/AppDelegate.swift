//
//  AppDelegate.swift
//  ChatHook8
//
//  Created by Kevin Farm on 9/27/16.
//  Copyright © 2016 splashscene. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FirebaseInstanceID
import FirebaseMessaging
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        PushNotificationManager.push().delegate = self
        PushNotificationManager.push().handlePushReceived(launchOptions)
        PushNotificationManager.push().sendAppOpen()
        PushNotificationManager.push().registerForPushNotifications()
        /*
        let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]){(granted, error) in
            
        }
        
         Local Notifications
         let content = UNMutableNotificationContent()
            content.title = "Introduction to Notifications"
            content.subtitle = "Session 707"
            content.body = "Woah! These new notifications look amazing! Don't you agree?"
            content.badge = 1
         
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let requestIdentifier = "sampleRequest"
            let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
         
         center.add(request){(error) in
         }
         
         Remote Notifications
         {
            "aps" : {
                "alert" {
                    "title": "Introduction to Notifications",
                    "subtitle": "Session 707",
                    "body": "Woah! These new notifications look amazing! Don't you agree?"
                },
            "badge": 1
            },
         
         }
         
         if application in foreground
         protocol UNUserNotificationCenterDelegate: NSObjectProtocol
         func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
         //handle responses
         func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void)
         
         
         //Roll banner and sound alert
         handlerBlock([.alert,.sound])
         
         Request Identifier
         Local Notifications - Set on Notification Request
         Remote Notifications - New field on the HTTP/2 request header: apns-collapse-id
         
         //Pending Notification Removal
         let gameStartIdentifier = "game1.start.identifier"
         let gameStartRequest = UNNotificationRequest(identifier: gameStartIdentifier, content: content, trigger: startTrigger)
         
         UNUserNotificationCenter.current().add(gameStartRequest){(error) in //....}
         
         //Game was cancelled
         UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [gameStartIdentifier])
         
         Three types of actions for received notifications
            Default Action - tap on notification to open the app
            Actionable - Buttons with customizable title, text input, background or foreground
         
         Register Actionable Notifications
         let action = UNNotificationAction(identifier: "reply", title: "Reply", options: [])
         let category = UNNotificationCategory(identifier: "message", actions: [action], minimalActions: [action], intentIdentifiers: [], options: [])
         center.setNotificationCategories([category])
         
         Present Actionable Notifications
         Remote Notifications
         {
            aps: {
                alert: "Welcome to WWDC!",
                category: "message"
                }
         }
         
         Local Notifications
         add: content.categoryIdentifier = "message" to content created above
         
         Dismiss Action
         customDismissAction: UNNotificationCategoryOptions
         
         let category = UNNotificationCategory(identifier: "message", actions: [action], minimalActions: [action], intentIdentifiers: [], options: [.customDismissAction])
         
         
 
        
        if #available(iOS 8.0, *){
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }else{
            let types: UIRemoteNotificationType = [.alert, .badge, .sound]
            application.registerForRemoteNotifications(matching: types)
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
 */
        
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
        //return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
       FBSDKAppEvents.activateApp()
        //connectToFCM()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.push().handlePushRegistration(deviceToken as Data!)
    }
    func onDidFailToRegisterForRemoteNotificationsWithError(_ error: Error!) {
        PushNotificationManager.push().handlePushRegistrationFailure(error)
    }
     private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
     
     }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationManager.push().handlePushReceived(userInfo)
    }
    
    func onPushAccepted(_ pushManager: PushNotificationManager!, withNotification pushNotification: [AnyHashable : Any]!) {
        print("Push notification accepted: \(pushNotification)");
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
    /*
    func tokenRefreshNotification(notification: NSNotification){
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("InstanceID token: \(refreshedToken)")
        connectToFCM()
    }
    
    func connectToFCM(){
        FIRMessaging.messaging().connect { (error) in
            if error != nil{
                print("Unable to Connect")
            }else{
                print("Connected to FCM")
            }
        }
    }
 */

}

