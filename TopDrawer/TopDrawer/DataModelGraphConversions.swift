//
//  DataModelGraphConversions.swift
//  TopDrawer
//
//  Created by Carl Udren on 5/16/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph
import CloudKit

extension Page {
    class func pageFromEntity(entity: Entity) -> Page {
        
        let image = entity["image"] as? UIImage ?? nil
        let name = entity["name"] as? String ?? nil
        let description = entity["description"] as? String ?? nil
        let date = entity["date"] as? NSDate ?? nil
        let URLString = entity["URLString"] as? String ?? nil
        let id = entity["recordID"] as! String
        let modifiedDate = entity["modificationDate"] as? NSDate
        let isPublic = entity["isPublic"] as? Bool
        let topics = entity["topic"] as? [String]
        let newPage = Page(name: name, description: description, URLString: URLString, image: image, date: date, recordID: id, modifiedDate: modifiedDate!, isPublic: isPublic!, topics: topics)
        
        return newPage
        
    }
}

extension TopicMarker {
    class func topicMarkerFromEntity(entity: Entity) -> TopicMarker {
        let page = entity["page"] as? String
        let date = entity["date"] as? NSDate
        let topicID = entity["topic"] as? String
        return TopicMarker(page: page, date: date, topic: topicID)
    }
}

extension Topic {
    class func topicFromEntity(entity: Entity) -> Topic {
        let name = entity["name"] as? String
        let users = entity["friends"] as? [String]
        let recordID = entity["recordID"] as? String
        
        return Topic(name: name, users: users, recordID: recordID)
    }
}

extension Friend {
    class func friendFomEntity(entity: Entity) -> Friend {
        let firstName = entity["givenName"] as? String
        let familyName = entity["familyName"] as? String
        let recordID = entity["recordID"] as! String
        let userImage = entity["image"] as? UIImage
        
        return Friend(firstName: firstName, familyName: familyName, recordIDString: recordID, image: userImage)
    }
}

extension Message {
    class func messageFromEntity(entity: Entity) -> Message{
        let friend = entity["sender"] as? String
        let body = entity["body"] as? String
        let topic = entity["topic"] as? String
        let date = entity["date"] as? NSDate
        return Message(sender: friend, body: body, topic: topic, date: date)
    }
}
