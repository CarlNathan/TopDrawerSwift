//
//  CloudKitSavingServices.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class CloudKitSavingServices: CloudKitAbstract, TopDrawerRemoteSavingAssistant {
    
    
    func saveMessage(message: Message, completion: (Message)->Void) {
        let record = CKRecord(recordType: RecordType.Message.rawValue)
        record["body"] = message.body
        let sender = CKReference(recordID: CKRecordID(recordName: message.sender!), action: .None)
        record["sender"] = sender
        let topic = CKReference(recordID: CKRecordID(recordName: message.topicRef!), action: .None)
        record["topic"] = topic

        savePublicRecord(record) { (savedRecord) in
            message.date = savedRecord.creationDate
            completion(message)
        }
    }
    
    
    func saveTopicMarker(topicMarker: TopicMarker, completion: (TopicMarker)->Void) {
        let record = CKRecord(recordType: RecordType.TopicMarker.rawValue)
        let sender = CKReference(recordID: CKRecordID(recordName: topicMarker.page!), action: .None)
        record["page"] = sender
        let topic = CKReference(recordID: CKRecordID(recordName: topicMarker.topicID!), action: .None)
        record["topic"] = topic
            
        savePublicRecord(record) { (savedRecord) in
            topicMarker.date = savedRecord.creationDate
            completion(topicMarker)
        }
    }
        
    func createNewPrivateTopic(topic: Topic, completion: (Topic)->Void) {
        let record = CKRecord(recordType: RecordType.PrivateTopic.rawValue)
        record["name"] = topic.name
        savePrivateRecord(record) { (savedRecord) in
            topic.recordID = savedRecord.recordID.recordName
            completion(topic)
        }
    }
    
    func createNewSharedTopic(topic: Topic, completion: (Topic)->Void) {
        let record = CKRecord(recordType: RecordType.PublicTopic.rawValue)
        record["name"] = topic.name
        var userRefs: [CKReference] = [CKReference]()
        for user in topic.users! {
            userRefs.append(CKReference(recordID: CKRecordID(recordName: user), action: .None))
        }
        record["users"] = userRefs
        savePublicRecord(record) { (savedRecord) in
            topic.recordID = savedRecord.recordID.recordName
            completion(topic)
        }
    }
    
    
    func assignPageToPrivateTopics(page: Page, topics: [String], completion: (Page)->Void) {
        modifyPrivateRecord(page, modifications: { (oldPage) -> CKRecord in
            var newTopics = [CKReference]()
            for ref in topics {
                newTopics.append(CKReference(recordID: CKRecordID(recordName: ref), action: .None))
            }
            oldPage["topic"] = newTopics
            return oldPage
            }) { (savedPage) in
                var topics = [String]()
                for savedTopic in savedPage["topic"] as! [CKReference] {
                    topics.append(savedTopic.recordID.recordName)
                }
                page.topic = topics
                completion(page)
        }
    }
    
    
    func assignPageToPublicTopics(page: Page, topics:[String], completion: (Page)->Void) {
        let pageRecord = CKRecord(recordType: RecordType.Page.rawValue)
        
        pageRecord["name"] = page.name
        pageRecord["description"] = page.description
        pageRecord["date"] = NSDate()
        pageRecord["URLString"] = page.URLString
        var references = [CKReference]()
        for topic in topics {
            references.append(CKReference(recordID: CKRecordID(recordName: topic), action: .None))
        }
        pageRecord["topic"] = references
        if let image = page.image {
            let data = UIImagePNGRepresentation(image)
            let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let path = directory.path! + "/\(page.name).png"
            data!.writeToFile(path, atomically: false)
            pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        }

        savePublicRecord(pageRecord) { (savedRecord) in
            page.pageID = savedRecord.recordID.recordName
        }
    }

}

