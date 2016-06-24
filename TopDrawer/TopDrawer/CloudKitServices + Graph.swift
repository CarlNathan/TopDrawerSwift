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


class CloudKitGraphCoordinator: CloudKitAbstract, TopDrawerDataCoordinator {
    
    private var user: PersistedUser?
    
    func setUser(user: PersistedUser?) {
        self.user = user
    }
    
    // MARK: Properties
    
    private let graph = Graph()
    
    
    // MARK: Manage User
    
    func getCurrentUserID (completion: (String)->Void, failed: ()->Void) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler { (user, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
            }
            if let userID = user {
                completion(userID.recordName)
            } else {
                failed()
            }
        }
    }
    
    private func createSearchableUser() {
        let persistedUserID = user!.ID
        let predicate = NSPredicate(format:"(userID == %@)", persistedUserID)
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
    
    func updateUserDisplayData(image: UIImage, displayName: String) {
        let persistedUserID = user!.ID
        let predicate = NSPredicate(format:"(userID == %@)", persistedUserID)
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
    
    
    func findFriends(completionHandler: () -> Void)  {
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
    
    private func fetchUserImage(recordID: CKRecordID, completion: (UIImage?)->Void) {
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
    
    func fetchUserFromID(recordID: String, completion: ()-> Void) {
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

extension CloudKitGraphCoordinator {
    // MARK: Topics
    func getPublicTopics(completion: ()->Void) {
        let predicate = NSPredicate(format: "%K CONTAINS %@", "users", CKRecordID(recordName: user!.ID))
        performPublicQuerry(RecordType.PrivateTopic, predicate: predicate, sortDescriptors: nil) { (records) in
            if let topics = records {
                var flag: Bool = false
                for topic in topics {
                    let graphTopics = self.graph.searchForEntity(types: [EntityType.PublicTopic.rawValue], groups: nil, properties: nil)
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
                self.graph.save()
                }
                completion()
            }
        }
    }
    
    func getPrivateTopics(completion: ()-> Void) {
        performPrivateQuerry(RecordType.PrivateTopic, predicate: nil, sortDescriptors: nil) { (records) in
            if let topics = records {
                var flag: Bool = false
                for topic in topics {
                    let graphTopics = self.graph.searchForEntity(types: [EntityType.PrivateTopic.rawValue], groups: nil, properties: nil)
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
    
    func getItemsForTopic(topicID: String, completion: ()-> Void) {
        let recordID = CKRecordID(recordName: topicID)
        self.getMessagesForTopic(recordID)
        self.getTopicMarkersForTopic(recordID)
        self.getPagesForTopic(recordID)
        completion()
    }
    
    //MARK: Pages
   
    private func getPagesForTopic(topicID: CKRecordID) {
        
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
                    let topics = page["topic"] as! [CKReference]
                    var topicStrings = [String]()
                    for topic in topics {
                        topicStrings.append(topic.recordID.recordName)
                    }
                    newPage["topic"] = topicStrings
                }
                self.graph.save()
            }
        }
    }
    
    func fetchPrivatePages(completion: (PersistedUser) -> Void) {
        
        let lastUpdate = user!.privatePagesUpdated
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
                    newPage["isPublic"] = false
                    
                }
                self.graph.save()
                var updatedUser = self.user
                updatedUser!.privatePagesUpdated = NSDate()
                completion(updatedUser!)
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
                newMessage["date"] = message.creationDate
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
                    newTopicMarker["date"] = topicMarker.creationDate
                    let page = topicMarker["page"] as! CKReference
                    newTopicMarker["page"] = page.recordID.recordName
                    let topic = topicMarker["topic"] as! CKReference
                    newTopicMarker["topic"] = topic.recordID.recordName
                }
                self.graph.save()
            }
        }

    }

}

