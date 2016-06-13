//
//  CloudKit + Graph Services.swift
//  TopDrawer
//
//  Created by Carl Udren on 5/9/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit
import Graph
import UIKit

class MissionControl {
    static let sharedInstance = MissionControl()
    let graph = Graph()
    var currentUserID: CKRecordID!
    var friends = [String:Friend] ()
    
    //Get Current user
    
    func getCurrentUserID () {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler { (userID, error) -> Void in
            if let e = error {
                print("0 failed to load: \(e.localizedDescription)")
                return
            }
            if let user = userID {
                self.currentUserID = user
                let defaults = NSUserDefaults.standardUserDefaults()
                if !(defaults.objectForKey("TopicSubscriptionCreated") as? Bool ?? false) {
                    self.createRemoteTopicSubscription()
                }
                
            }
        }
    }
    
     //Fetch New Friends -> Graph
    
    func findUsers(completionHandler: () -> Void)  {
        let container = CKContainer.defaultContainer()
        container.discoverAllContactUserInfosWithCompletionHandler { (userInfo, error) -> Void in
            if let e = error {
                print("1: failed to load: \(e.localizedDescription)")
                return
            }
            for user in userInfo! {
                let newFriend = self.friendFromCKDiscoveredUser(user)
                let CKID = user.userRecordID?.recordName
                self.friends[CKID!] = newFriend
                
                let friend = Entity(type: "Friend")
                friend["givenName"] = user.displayContact?.givenName
                friend["familyName"] = user.displayContact?.familyName
                friend["recordID"] = user.userRecordID?.recordName
            }
            self.graph.save()
            completionHandler()
        }
    }
    
    func friendFromCKDiscoveredUser (user: CKDiscoveredUserInfo) -> Friend {
        let newFriend = Friend(firstName: (user.displayContact?.givenName)!, familyName: (user.displayContact?.familyName)!, recordIDString: (user.userRecordID?.recordName)!)
        return newFriend
    }
    
    func getPermissions() {
        CKContainer.defaultContainer().requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(true, forKey: "UserDiscoverabilityEnabled")
                self.findUsers({
                    //
                })
            }
        })
        
    }



    
    //Fetch New Friends -> Graph
    //Fetch Friends From Messages -> Graph
    //Fetch New Saved Pages ->Graph
    //Fetch New Topics -> Graph
    //Fetch New Messages -> Graph (And possibly delete messages one they are persisted. (+) security (-) backup.
    
    //Get Data From Graph
    
}

extension MissionControl {
   
    func getPersonalPages(lastUpdate: NSDate, completionHandler: ([Page]?) -> Void){
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(format:"(modificationDate > %@)", lastUpdate)
        let querry = CKQuery(recordType: "Page", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (Pages, error) -> Void in
            if let e = error {
                print("2: failed to load: \(e.localizedDescription)")
                return
            }
            for page in Pages! {
                
                var image = UIImage()
                if let imageAsset = page["image"] as? CKAsset ?? nil {
                    image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                }
                
                let newPage = Entity(type: "PersonalPage")
                newPage["name"] = page["name"] as? String ?? nil
                newPage["description"] = page["description"] as? String ?? nil
                newPage["date"] = page["date"] as? NSDate ?? nil
                newPage ["URLString"] = page["URLString"] as? String ?? nil
                newPage["image"] = image
                newPage["recordID"] = page.recordID
                newPage["modificationDate"] = page.modificationDate
            }
            self.graph.save()
            completionHandler(nil)
        }
    }
}

extension MissionControl {
    
    func createRemoteTopicSubscription() {
        let predicate = NSPredicate(format: "%K CONTAINS %@" , "users", CKReference(recordID: self.currentUserID, action: .None))
        let subscription = CKSubscription(recordType: "PublicTopic", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "New Topic"
        subscription.notificationInfo = notificationInfo
        
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveSubscription(subscription) { (subscription, error) -> Void in
            if let e = error {
                print("19: failed to load: \(e.localizedDescription)")
                return
            }
            
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(true, forKey: "TopicSubscriptionCreated")
        }
        
        
    }

}