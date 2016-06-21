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

protocol PersistedUserManagerProtocol {
    func persistUser(userObject: PersistedUser)
    func wipeUser() -> Void
    func fetchLastUser() -> PersistedUser?
    func generateNewPersistedUser(userID: String) -> PersistedUser
}

class MissionControl {
    
    func startupSequence() {
        signIn {
            //once we have user
            //1. GetFriends
            //2. Get Pages
            //3. Get Topics
            self.findUsers({
                DataSource.sharedInstance.updateFriends()
            })
            self.getPublicTopics({
                //
            })
            self.getPrivateTopics({
                //
            })
            self.fetchPrivatePages({
                //
            })
        }
    }
    
    // MARK: Properties
    
    static let sharedInstance = MissionControl()
    private let graph = Graph()
    var user: PersistedUser?
    private let userManager: PersistedUserManagerProtocol = PersistedUserManager()
    
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

    
    // MARK: Manage User
    
    func signIn(completion: ()->Void) {
        user = userManager.fetchLastUser()
        getCurrentUserID({ userID in
            if self.user == nil {
                self.user = self.userManager.generateNewPersistedUser(userID.recordName)
                self.userManager.persistUser(self.user!)
            }
            if userID.recordName != self.user!.ID {
                GraphServices().wipePersistedData()
                self.user = self.userManager.generateNewPersistedUser(userID.recordName)
                self.userManager.persistUser(self.user!)
            }
            completion()
            }) { 
                //failed to get user: FIX ME: prompt sign in
        }
    }
    
    private func getCurrentUserID (completion: (CKRecordID)->Void, failed: ()->Void) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler { (user, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
            }
            if let userID = user {
                completion(userID)
                //self.createRemoteTopicSubscription()
            } else {
                failed()
            }
        }
    }
    
    private func createSearchableUser() {
        let persistedUserID = userManager.fetchLastUser()?.ID
        let predicate = NSPredicate(format:"(userID == %@)", persistedUserID!)
        performPublicQuerry(RecordType.User, predicate: predicate, sortDescriptors: nil) { (records) in
            if records == nil || records!.count == 0 {
                let user = CKRecord(recordType: RecordType.User.rawValue)
                user["recordID"] = persistedUserID
                user["displayName"] = "Unknown User"
                let DB = CKContainer.defaultContainer().publicCloudDatabase
                DB.saveRecord(user, completionHandler: { (record, error) in
                    if let e = error {
                        self.provideErrorMessage(e)
                    } else {
                        print(record)
                    }
                })
            }
        }
        
    }
    
    func updateSearchableUser(image: UIImage, displayName: String) {
        let persistedUserID = userManager.fetchLastUser()?.ID
        let predicate = NSPredicate(format:"(userID == %@)", persistedUserID!)
        performPublicQuerry(RecordType.User, predicate: predicate, sortDescriptors: nil) { (records) in
            if let users = records {
                let user = users[0]
                user["recordID"] = persistedUserID
                user["displayName"] = displayName
                let data = UIImagePNGRepresentation(image)
                let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
                let path = directory.path! + "/\(displayName).png"
                data!.writeToFile(path, atomically: false)
                user["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
                let DB = CKContainer.defaultContainer().publicCloudDatabase
                DB.saveRecord(user, completionHandler: { (record, error) in
                    if let e = error {
                        self.provideErrorMessage(e)
                    } else {
                        print(record)
                    }
                })
            }
        }
        
    }

    
    // MARK: Friend Data Type
    
    
    func findUsers(completionHandler: () -> Void)  {
        let container = CKContainer.defaultContainer()
        let dispatchGroup = dispatch_group_create()
        container.discoverAllContactUserInfosWithCompletionHandler { (userInfo, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
                return
            }
            let friends = self.graph.searchForEntity(types: [EntityType.Friend.rawValue], groups: nil, properties: nil)
            for user in userInfo! {
                var flag: Bool = false
                for friend in friends {
                    if friend["recordID"] as? String == user.userRecordID?.recordName {
                        flag = true
                    }
                    if friend["email"] != nil && friend["recordID"] as? String == user.userRecordID?.recordName {
                        friend.delete()
                    }
                }
                
                if !flag {
                    let friend = Entity(type: "Friend")
                    friend["givenName"] = user.displayContact?.givenName
                    friend["familyName"] = user.displayContact?.familyName
                    friend["recordID"] = user.userRecordID?.recordName
                    dispatch_group_enter(dispatchGroup)
                    self.fetchUserImage(user.userRecordID!, completion: { (image) in
                        if image != nil {
                            friend["image"] = image!
                        }
                        dispatch_group_leave(dispatchGroup)
                    })
                    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER)
                }
            }
            self.graph.save()
            completionHandler()
        }
    }
    
    func fetchUserImage(recordID: CKRecordID, completion: (UIImage?)->Void) {
        let predicate = NSPredicate(format:"(userID == %@)", recordID.recordName)
        performPublicQuerry(RecordType.User, predicate: predicate, sortDescriptors: nil) { (records) in
            if records!.count > 0 {
                let record = records![0]
                if let imageAsset = record["image"] as? CKAsset {
                    let image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
                    completion(image)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUserFromRecordID(recordID: String, completion: ()-> Void) {
        let predicate = NSPredicate(format:"(userID == %@)", recordID)
        performPublicQuerry(RecordType.User, predicate: predicate, sortDescriptors: nil) { (records) in
            if let users = records {
                for user in users {
                    let friend = Entity(type: RecordType.Friend.rawValue)
                    friend["recordID"] = user["userID"] as? String
                    friend["email"] = user["email"] as? String
                    if let imageAsset = user["image"] as? CKAsset {
                        friend["image"] = UIImage(contentsOfFile: imageAsset.fileURL.path!)
                    }
                }
            }
        }
    }
}

extension MissionControl {
    // MARK: Topics
    func getPublicTopics(completion: ()->Void) {
        let predicate = NSPredicate(format: "%K CONTAINS %@", "users", CKRecordID(recordName: user!.ID))
        performPublicQuerry(RecordType.Topic, predicate: predicate, sortDescriptors: nil) { (records) in
            if let topics = records {
                var flag: Bool = false
                for topic in topics {
                    let graphTopics = self.graph.searchForEntity(types: [RecordType.Topic.rawValue], groups: nil, properties: nil)
                    for graphTopic in graphTopics {
                        if graphTopic["recordID"] as! String == topic.recordID.recordName {
                            flag = true
                        }
                    }
                    if !flag {
                        let newTopic = Entity(type: EntityType.PublicTopic.rawValue)
                        newTopic["name"] = topic["name"]
                        newTopic["recordID"] = topic.recordID.recordName
                        let users = topic["users"] as! [CKReference]
                        var userIDs = [String]()
                        for user in users {
                            userIDs.append(user.recordID.recordName)
                        }
                        newTopic["friends"] = userIDs
                        self.getMessagesForTopic(topic.recordID)
                        self.getTopicMarkersForTopic(topic.recordID)
                        self.getPagesForTopic(topic.recordID)
                    }
                }
                self.graph.save()
                completion()
            }
        }
    }
    
    func getPrivateTopics(completion: ()-> Void) {
        performPrivateQuerry(RecordType.Topic, predicate: nil, sortDescriptors: nil) { (records) in
            if let topics = records {
                var flag: Bool = false
                for topic in topics {
                    let graphTopics = self.graph.searchForEntity(types: [RecordType.Topic.rawValue], groups: nil, properties: nil)
                    for graphTopic in graphTopics {
                        if graphTopic["recordID"] as! String == topic.recordID.recordName {
                            flag = true
                        }
                    }
                    if !flag {
                        let newTopic = Entity(type: EntityType.PrivateTopic.rawValue)
                        newTopic["name"] = topic["name"]
                        newTopic["recordID"] = topic.recordID.recordName
                    }
                }
                self.graph.save()
                completion()
            }
        }

    }
    
    //MARK: Pages
   
    func getPagesForTopic(topicID: CKRecordID) {
        
        let ref = CKReference(recordID: topicID, action: .None)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", ref)
        performPublicQuerry(RecordType.Page, predicate: predicate, sortDescriptors: nil) { (records) in
            if let pages = records {
                for page in pages {
                    
                    var image: UIImage?
                    if let imageAsset = page["image"] as? CKAsset ?? nil {
                        image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                    }
                    
                    let newPage = Entity(type: EntityType.PublicPage.rawValue)
                    newPage["name"] = page["name"] as? String
                    newPage["description"] = page["description"] as? String
                    newPage["date"] = page["date"] as? NSDate
                    newPage ["URLString"] = page["URLString"] as? String
                    newPage["image"] = image
                    newPage["recordID"] = page.recordID.recordName
                    newPage["modificationDate"] = page.modificationDate
                    newPage["isPublic"] = true
                    let topic = page["topic"] as! CKReference
                    newPage["topic"] = topic.recordID.recordName
                }
                self.graph.save()
            }
        }
    }
    
    func fetchPrivatePages(completion: () -> Void) {
        
        let lastUpdate = userManager.fetchLastUser()!.privatePagesUpdated
        let predicate = NSPredicate(format:"(modificationDate > %@)", lastUpdate)
        performPrivateQuerry(RecordType.Page, predicate: predicate, sortDescriptors: nil) { (records) in
            if let pages = records {
                for page in pages {
                    
                    var image: UIImage?
                    if let imageAsset = page["image"] as? CKAsset ?? nil {
                        image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                    }
                    
                    let newPage = Entity(type: EntityType.PrivatePage.rawValue)
                    newPage["name"] = page["name"] as? String
                    newPage["description"] = page["description"] as? String
                    newPage["date"] = page["date"] as? NSDate
                    newPage ["URLString"] = page["URLString"] as? String
                    newPage["image"] = image
                    newPage["recordID"] = page.recordID.recordName
                    newPage["modificationDate"] = page.modificationDate
                    newPage["isPublic"] = true
                }
                self.graph.save()
                var user = self.userManager.fetchLastUser()!
                user.privatePagesUpdated = NSDate()
                self.userManager.persistUser(user)
                completion()
            }
        }

    }

    // MARK: Messages
    
    private func getMessagesForTopic(recordID: CKRecordID) {
        let ref = CKReference(recordID: recordID, action: .None)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", ref)
       performPublicQuerry(RecordType.Message, predicate: predicate, sortDescriptors: nil) { (records) in
        if let messages = records {
            for message in messages {
                let newMessage = Entity(type: EntityType.Message.rawValue)
                newMessage["body"] = message["body"] as? String
                let sender = message["sender"] as! CKReference
                newMessage["sender"] = sender.recordID.recordName
                let topic = message["topic"] as! CKReference
                newMessage["topic"] = topic.recordID.recordName
            }
            self.graph.save()
        }
        }
    }
    
    // MARK: TopicMarkers
    
    private func getTopicMarkersForTopic(recordID: CKRecordID) {
        let ref = CKReference(recordID: recordID, action: .None)
        let predicate = NSPredicate(format: "%K == %@", "topic", ref)
        performPublicQuerry(RecordType.TopicMarker, predicate: predicate, sortDescriptors: nil) { (records) in
            if let topicMarkers = records {
                for topicMarker in topicMarkers {
                    let newTopicMarker = Entity(type: EntityType.TopicMarker.rawValue)
                    newTopicMarker["date"] = topicMarker["date"] as? NSDate
                    let page = topicMarker["page"] as! CKReference
                    newTopicMarker["page"] = page.recordID.recordName
                    let topic = topicMarker["topic"] as! CKReference
                    newTopicMarker["topic"] = topic.recordID.recordName
                }
                self.graph.save()
            }
        }

    }
    
    // MARK: Subscriptions
    
    func createRemoteTopicSubscription() {
        let predicate = NSPredicate(format: "%K CONTAINS %@" , "users", CKRecordID(recordName: user!.ID))
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "New Topic"
        
        createPublicPushSubscription(RecordType.Topic, predicate: predicate, notificationInfo: notificationInfo) { (subscription) in
            print(subscription)
        }
    }
    
    func createSubscriptions (recordID: CKRecordID) {
        
        let messageRef = CKReference(recordID: recordID, action: .None)
        let messagePredicate = NSPredicate(format: "%K CONTAINS %@" , "topic", [messageRef])
        let pageRef = CKReference(recordID: recordID, action: .None)
        let pagePredicate = NSPredicate(format: "%K CONTAINS %@", "topic", [pageRef])
        let markerRef = CKReference(recordID: recordID, action: .None)
        let markerPredicate = NSPredicate(format: "%K = %@" , "topic", markerRef)
        
        let messageNotificationInfo = CKNotificationInfo()
        messageNotificationInfo.shouldBadge = true
        messageNotificationInfo.shouldSendContentAvailable = true
        messageNotificationInfo.alertBody = "New Message"
        
        let pageNotificationInfo = CKNotificationInfo()
        pageNotificationInfo.shouldBadge = true
        pageNotificationInfo.shouldSendContentAvailable = true
        pageNotificationInfo.alertBody = "New Page"
        
        let markerNotificationInfo = CKNotificationInfo()
        markerNotificationInfo.shouldBadge = true
        markerNotificationInfo.shouldSendContentAvailable = true
        markerNotificationInfo.alertBody = "New Marker"
        
        createPublicPushSubscription(RecordType.Message, predicate: messagePredicate, notificationInfo: messageNotificationInfo) { (messageSubscription) in
            print(messageSubscription)
        }
        
        createPublicPushSubscription(RecordType.Page, predicate: pagePredicate, notificationInfo: pageNotificationInfo) { (pageSubscription) in
            print(pageSubscription)
        }
        
        createPublicPushSubscription(RecordType.TopicMarker, predicate: markerPredicate, notificationInfo: markerNotificationInfo) { (markerSubscription) in
            print(markerSubscription)
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