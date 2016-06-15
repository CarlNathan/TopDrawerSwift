//
//  AppDelegate.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit
import Graph

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var lastUpdate = NSDate(timeIntervalSince1970: NSTimeInterval(0))


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let graph = Graph()
        let items = graph.searchForEntity(types: ["PersonalPage"], groups: nil, properties: nil)
//        for item in items {
//            item.delete()
//        }
        for item in items {
            let date = item["modificationDate"] as! NSDate
            if date.compare(lastUpdate) == .OrderedDescending {
                lastUpdate = item["date"] as! NSDate
            }
        }
        InboxManager.sharedInstance.initFriends()
        InboxManager.sharedInstance.getCurrentUserID()
        MissionControl.sharedInstance.fetchPrivatePages(lastUpdate) { (Pages) in
            //
        }
        
        
        // Register for push notifications
        let notificationSettings = UIUserNotificationSettings.init(forTypes: UIUserNotificationType.Alert, categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        
        if let pushInfo = userInfo as? [String: NSObject] {
            
            
            let notification = CKNotification(fromRemoteNotificationDictionary: pushInfo)
            let alertBody = notification.alertBody
            
            print(alertBody)
            if let queryNotification = notification as? CKQueryNotification {
                let recordID = queryNotification.recordID
                guard let body = queryNotification.alertBody else {
                    return
                }
                
                
                switch body {
                case "New Topic":
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RemoteTopic", object: self, userInfo: ["topicID":recordID!]))
                    InboxManager.sharedInstance.createSubscriptions(recordID!)
                    break
                case "New Page":
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RemotePage", object: self, userInfo: ["topicID":recordID!]))
                    break
                case "New Message":
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RemoteMessage", object: self, userInfo: ["topicID":recordID!]))
                    break
                case "New Marker":
                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "RemoteMarker", object: self, userInfo: ["topicID":recordID!]))
                    break
                default:
                    return
                }
            }
    }

}
}

