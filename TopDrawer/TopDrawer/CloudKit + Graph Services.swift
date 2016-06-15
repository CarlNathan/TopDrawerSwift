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
    
    // MARK: Properties
    
    static let sharedInstance = MissionControl()
    private let graph = Graph()
    var friends = [String:Friend] ()
    var user: PersistedUser?
    private let userManager = PersistedUserManager()
    
    // MARK: Manage User
    
//    func signIn() {
////        user = userManager.fetchLastUser()
////        getCurrentUserID({ user in
////            if user
////            }) { 
////                //prompt sign in
////        }
//    }
    
    // MARK: Friend Data Type
    
    private func getCurrentUserID (completion: (CKRecordID)->Void, failed: ()->Void) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler { (user, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
            }
            if let userID = user {
                self.createRemoteTopicSubscription()
                completion(userID)
            } else {
                failed()
            }
        }
    }
    
    
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
        let givenName = user.displayContact?.givenName
        let familyName = user.displayContact?.familyName
        
        let newFriend = Friend(firstName: (user.displayContact?.givenName)!, familyName: (user.displayContact?.familyName)!, recordIDString: (user.userRecordID?.recordName)!, image: nil)
        return newFriend
    }
    
    func getUserImages(){
        let container = CKContainer.defaultContainer()
        let DB = container.publicCloudDatabase
        let predicate = NSPredicate(value: true)
    }
    
    // MARK: Permissions
    
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
   
    func fetchPrivatePages(lastUpdate: NSDate, completionHandler: () -> Void){
        
        let predicate = NSPredicate(format:"(modificationDate > %@)", lastUpdate)
        
        performPrivateQuerry(RecordType.Page, predicate: predicate, sortDescriptors: nil) { (records) in
            if let pages = records {
                for page in pages {
                    
                    var image: UIImage?
                    if let imageAsset = page["image"] as? CKAsset ?? nil {
                        image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                    }
                    
                    let newPage = Entity(type: "PrivatePage")
                    newPage["name"] = page["name"] as? String
                    newPage["description"] = page["description"] as? String
                    newPage["date"] = page["date"] as? NSDate
                    newPage ["URLString"] = page["URLString"] as? String
                    newPage["image"] = image
                    newPage["recordID"] = page.recordID
                    newPage["modificationDate"] = page.modificationDate
                }
                self.graph.save()
                completionHandler()
            }
        }
    }

    
    func createRemoteTopicSubscription() {
        let predicate = NSPredicate(format: "%K CONTAINS %@" , "users", CKReference(recordID: self.user!.ID, action: .None))
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "New Topic"
        
        createPublicPushSubscription(RecordType.Topic, predicate: predicate, notificationInfo: notificationInfo) { (subscription) in
            print(subscription)
        }
        
        
    }
    
    private func createPublicPushSubscription(recordType: RecordType, predicate: NSPredicate, notificationInfo: CKNotificationInfo, completion: (CKSubscription?)->Void){
        let DB = CKContainer.defaultContainer().publicCloudDatabase
        let subscription = CKSubscription(recordType: recordType.rawValue, predicate: predicate, options: .FiresOnRecordCreation)
        subscription.notificationInfo = notificationInfo
        DB.saveSubscription(subscription) { (savedSubscription, error) in
            if let e = error {
                self.provideErrorMessage(e)
            } else {
                completion(savedSubscription)
            }
        }
    }
}

extension MissionControl {
    
    // MARK: Perform Cloud Kit Querry
    
    private func performPublicQuerry(recordType: RecordType, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: ([CKRecord]?)->Void){
        let container = CKContainer.defaultContainer()
        let DB = container.publicCloudDatabase
        let pred = predicate ?? NSPredicate(value: true)
        let querry = CKQuery(recordType: recordType.rawValue, predicate: pred)
        if let sort = sortDescriptors {
            querry.sortDescriptors = sort
        }
        DB.performQuery(querry, inZoneWithID: nil) { (records, error) in
            if let e = error {
                self.provideErrorMessage(e)
                return
            } else {
                completion(records)
            }
        }
    }
    
    private func performPrivateQuerry(recordType: RecordType, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: ([CKRecord]?)->Void){
        let container = CKContainer.defaultContainer()
        let DB = container.privateCloudDatabase
        let pred = predicate ?? NSPredicate(value: true)
        let querry = CKQuery(recordType: recordType.rawValue, predicate: pred)
        if let sort = sortDescriptors {
            querry.sortDescriptors = sort
        }
        DB.performQuery(querry, inZoneWithID: nil) { (records, error) in
            if let e = error {
                self.provideErrorMessage(e)
                return
            } else {
                completion(records)
            }
        }
    }
    
    private func provideErrorMessage(error: NSError) {
        print(error.localizedDescription)
    }
}