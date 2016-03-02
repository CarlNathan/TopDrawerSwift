//
//  InboxManager.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit
import TopDrawerActionExtension
import UIKit

class InboxManager {
    
    static let sharedInstance = InboxManager()
    var friends = [String:Friend] ()
    var currentUserID: CKRecordID!
    
    func getCurrentUserID () {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler { (userID, error) -> Void in
            self.currentUserID = userID!
            self.createRemoteTopicSubscription()
        }
    }
    
    func findUsers() {
        let container = CKContainer.defaultContainer()
        container.discoverAllContactUserInfosWithCompletionHandler { (userInfo, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            for user in userInfo! {
                let newFriend = self.friendFromCKDiscoveredUser(user)
                let CKID = user.userRecordID?.recordName
                self.friends[CKID!] = newFriend
            }
        }
    }
    
    func friendFromCKDiscoveredUser (user: CKDiscoveredUserInfo) -> Friend {
        let newFriend = Friend(firstName: (user.displayContact?.givenName)!, familyName: (user.displayContact?.familyName)!, recordIDString: (user.userRecordID?.recordName)!)
        return newFriend
    }
}

extension InboxManager {
    
    func pageFromCKRecord (page:CKRecord)->Page {
        var image = UIImage()
        if let imageAsset = page["image"] as? CKAsset ?? nil {
            image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
        }
        let name = page["name"] as? String ?? nil
        let description = page["description"] as? String ?? nil
        let date = page["date"] as? NSDate ?? nil
        let URLString = page["URLString"] as? String ?? nil
        let newPage = Page(name: name, description: description, URLString: URLString, image: image, date:  date, recordID: page.recordID)
        return newPage
    }
    
    func getPersonalPages(completionHandler: ([Page]?) -> Void){
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "Page", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (Pages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            var newPages = [Page]()
            for page in Pages! {
                
                var image = UIImage()
                if let imageAsset = page["image"] as? CKAsset ?? nil {
                    image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                }
                let name = page["name"] as? String ?? nil
                let description = page["description"] as? String ?? nil
                let date = page["date"] as? NSDate ?? nil
                let URLString = page["URLString"] as? String ?? nil
                let newPage = Page(name: name, description: description, URLString: URLString, image: image, date:  date, recordID: page.recordID)
                newPages.append(newPage)
                
            }
            completionHandler(newPages)
        }

    }
    func checkURL (url: String, completionHandler: () -> Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(format: "%K = %@", "URLString", url)
        let querry = CKQuery(recordType: "Page", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (pages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            if pages!.count == 0 {
                completionHandler()
            }

        }
    }
    func savePersonalPage() {
        
    }
}

extension InboxManager {
    
    func initFriends() {
        self.getPermissions()
    }
    
    func getPermissions() {
            CKContainer.defaultContainer().requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
                if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                    self.findUsers()
                }
            })
            
        }
}

extension InboxManager {
    
    func getTopics(completionHandler: ([Topic]?) -> Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "Topic", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (Topics, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            var newTopics = [Topic]()
            for topic in Topics! {
                
                let name = topic["name"] as? String ?? nil
                let recordID = topic.recordID
                let newTopic = Topic(name: name!, users: [Friend](), recordID: recordID)
                newTopics.append(newTopic)
            }
            completionHandler(newTopics)
        }
    }
    
    func getPagesForTopic (topic:Topic, completionHandler: ([Page]?) -> Void) {
        self.getTopicID(topic) { (recordID) -> Void in
            self.getSavedPagesForPrivateTopic(recordID!, completionHandler: { (pages) -> Void in
                completionHandler(pages)
            })
        }
    }
    
    func getSavedPagesForPrivateTopic (topic: CKRecordID, completionHandler: ([Page]?) -> Void) {
    
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", topic)
    
        let querry = CKQuery(recordType: "Page", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (pages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            var newPages = [Page]()
            for page in pages! {

                
                var image = UIImage()
                if let imageAsset = page["image"] as? CKAsset ?? nil {
                    image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                }
                let name = page["name"] as? String ?? nil
                let description = page["description"] as? String ?? nil
                let date = page["date"] as? NSDate ?? nil
                let URLString = page["URLString"] as? String ?? nil
                let newPage = Page(name: name, description: description, URLString: URLString, image: image, date:  date, recordID: page.recordID)
                newPages.append(newPage)
    
            }
            completionHandler(newPages)
        }
    }
    
    func getTopicID (topic:Topic, completionHandler: (CKRecordID?) -> Void) {
        
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let predicate = NSPredicate(format: "%K = %@", "name", topic.name!)
        let querry = CKQuery(recordType: "Topic", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (topics, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            let ID = topics![0].recordID
            completionHandler(ID)
        }
        }

}

extension InboxManager {
    
    func getPublicTopics (completionHandler: ([Topic]?) -> Void) {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format: "%K CONTAINS %@", "users", self.currentUserID)
        let querry = CKQuery(recordType: "PublicTopic", predicate: predicate)
        publicDB.performQuery(querry, inZoneWithID: nil) { (publicTopics, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            var topics = [Topic]()
            for publicTopic in publicTopics! {
                let name = publicTopic["name"] as! String
                let users = publicTopic["users"] as! [CKReference]
                var userNames = [Friend]()
                for user in users {
                    if let newUser = self.friends[user.recordID.recordName]
                    {
                    userNames.append(newUser)
                    }
                    
                }
                topics.append(Topic(name: name, users: userNames, recordID: publicTopic.recordID))
            }
            completionHandler(topics)
        }
    }
    
    func getMessages (topic: Topic, completionHandler: ([Message]?) -> Void) {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        let ref = CKReference(recordID: topic.recordID!, action: .None)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", ref)
        let query = CKQuery(recordType: "Message", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (messages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            var newMessages = [Message]()
            for message in messages! {
                let body = message["body"] as! String
                let senderID = message["sender"] as! CKReference
                var sender: Friend!
                if senderID.recordID.recordName == self.currentUserID.recordName {
                    sender = Friend(firstName: "Me", familyName: "", recordIDString: self.currentUserID.recordName)
                } else {
                    sender = self.friends[senderID.recordID.recordName]

                }
                let date = message.creationDate
                let newMessage = Message(sender: sender!, body: body, topic: topic.recordID!, date: date!)
                newMessages.append(newMessage)
            }
            completionHandler(newMessages)
        }
    }
    
    func getPublicTopicPages (topic:Topic, completionHandler: ([Page]?) -> Void) {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        let ref = CKReference(recordID: topic.recordID!, action: .None)
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", ref)
        let query = CKQuery(recordType: "Page", predicate: predicate)
        publicDB.performQuery(query, inZoneWithID: nil) { (pages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
            }
            
            
            var newPages = [Page]()
            for page in pages! {
                
                var image = UIImage()
                if let imageAsset = page["image"] as? CKAsset ?? nil {
                    image = UIImage(contentsOfFile: imageAsset.fileURL.path!)!
                }
                let name = page["name"] as? String ?? nil
                let description = page["description"] as? String ?? nil
                let date = page["date"] as? NSDate ?? nil
                let URLString = page["URLString"] as? String ?? nil
                let newPage = Page(name: name, description: description, URLString: URLString, image: image, date:  date, recordID: page.recordID)
                newPages.append(newPage)
            }
            completionHandler(newPages)
        }

        }
    
    func savePageToTopics (page: Page, topics: [CKRecordID]) {
        let publicDB = CKContainer.defaultContainer().privateCloudDatabase
        var ref = [CKReference]()
        for record in topics {
            let reference = CKReference(recordID: record, action: .None)
            ref.append(reference)

        }
        publicDB.fetchRecordWithID(page.pageID) { (page, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            let oldReferences = page!["topic"] as? [CKReference] ?? [CKReference]()
            let newReferences = oldReferences + ref
            page?.setValue(newReferences, forKey: "topic")
            publicDB.saveRecord(page!, completionHandler: { (record, error) -> Void in
                if let e = error {
                    print("failed to load: \(e.localizedDescription)")
                    return
                }
            })
        }
    }
    
    func savePageToPublicTopics (page: Page, topics: [CKRecordID]) {
        
        let pageRecord = CKRecord(recordType: "Page")
        
        pageRecord["name"] = page.name
        pageRecord["description"] = page.description
        pageRecord["date"] = NSDate()
        pageRecord["URLString"] = page.URLString
        var references = [CKReference]()
        for topic in topics {
            references.append(CKReference(recordID: topic, action: .None))
        }
        pageRecord["topic"] = references
        if let image = page.image {
            let data = UIImagePNGRepresentation(image)
            let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let path = directory.path! + "/\(page.name).png"
            data!.writeToFile(path, atomically: false)
            pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        }
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveRecord(pageRecord) { (record, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
                }
            NSNotificationCenter.defaultCenter().postNotificationName("PageAddedToPublicTopic", object: self, userInfo: ["topics":topics , "page":page])
        }
        

    }

    func saveMessage(message: Message) {
        let messageRecord = CKRecord(recordType: "Message")
        
        messageRecord["body"] = message.body
        messageRecord["sender"] = CKReference(recordID: CKRecordID(recordName: message.sender.recordID!), action: .None)
        messageRecord["topic"] = [CKReference(recordID: message.topicRef, action: .None)]
        
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveRecord(messageRecord) { (record, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
        }
    }
    
    func createNewTopic (name: String) {
        let newTopic = CKRecord(recordType: "Topic")
        newTopic["name"] = name
        let publicDB = CKContainer.defaultContainer().privateCloudDatabase
        publicDB.saveRecord(newTopic) { (record, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            let name = record!["name"] as? String ?? nil
            let recordID = record!.recordID
            let newTopic = Topic(name: name!, users: [Friend](), recordID: recordID)
            NSNotificationCenter.defaultCenter().postNotificationName("NewTopic", object: self, userInfo: ["topic": newTopic])
        }
    }
    
    func createNewPublicTopic (name: String, users: [String]) {
        let newTopic = CKRecord(recordType: "PublicTopic")
        newTopic["name"] = name
        var references = [CKReference]()
        for user in users {
            let ref = CKReference(recordID: CKRecordID(recordName: user), action: .None)
            references.append(ref)
        }
        references.append(CKReference(recordID: self.currentUserID, action: .None))
        newTopic["users"] = references
        
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveRecord(newTopic) { (record, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            self.createSubscriptions(record!)
            let name = record!["name"] as! String
            let users = record!["users"] as! [CKReference]
            var userNames = [Friend]()
            for user in users {
                if let newUser = self.friends[user.recordID.recordName]
                {
                    userNames.append(newUser)
                }
                
            }
            let newTopic = Topic(name: name, users: userNames, recordID: record!.recordID)
            NSNotificationCenter.defaultCenter().postNotificationName("NewPublicTopic", object: self, userInfo: ["topic": newTopic])
        }
    }
}

extension InboxManager {
    
    func createSubscriptions (record: CKRecord) {
        
        let messagePredicate = NSPredicate(format: "%K CONTAINS %@" , "topic", record.recordID)
        let pagePredicate = NSPredicate(format: "%K CONTAINS %@", "topic", record.recordID)
        

        let messageSubscription = CKSubscription(recordType: "Message", predicate: messagePredicate, options: [CKSubscriptionOptions.FiresOnRecordCreation])
        let pageSubscription = CKSubscription(recordType: "Page", predicate: pagePredicate, options: [CKSubscriptionOptions.FiresOnRecordCreation])

        let messageNotificationInfo = CKNotificationInfo()
        messageNotificationInfo.shouldBadge = true
        messageNotificationInfo.shouldSendContentAvailable = true
        messageNotificationInfo.alertBody = "YouGotAnAltert"
        
        let pageNotificationInfo = CKNotificationInfo()
        pageNotificationInfo.shouldBadge = true
        pageNotificationInfo.shouldSendContentAvailable = true
        pageNotificationInfo.alertBody = "YouGotAnAltert"
        
        messageSubscription.notificationInfo = messageNotificationInfo
        pageSubscription.notificationInfo = pageNotificationInfo
        
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveSubscription(messageSubscription) { (messagesubscription, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
        }
        
        publicDB.saveSubscription(pageSubscription) { (pagesubscription, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
        }
        
    }
    
    func createRemoteTopicSubscription() {
        let predicate = NSPredicate(format: "%K CONTAINS %@" , "users", CKReference(recordID: self.currentUserID, action: .None))
        let subscription = CKSubscription(recordType: "PublicTopic", predicate: predicate, options: CKSubscriptionOptions.FiresOnRecordCreation)
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "YouGotAnAltert"
        subscription.notificationInfo = notificationInfo
        
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveSubscription(subscription) { (subscription, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
        }


    }
}


