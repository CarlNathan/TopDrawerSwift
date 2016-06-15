//
//  PersistedUserManager.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class PersistedUserManager {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //Constants
    let ID = "ID"
    let pagesUpdated = "pagesUpdated"
    let topicsUpdated = "topicsUpdated"
    let messagesUpdated = "messagesUpdated"
    let topicMarkersUpdated = "topicMarkersUpdated"
    let lastUser = "LastUser"

    func persistUser(userObject: PersistedUser){
        var userDictionary = Dictionary<String, AnyObject>()
        userDictionary[ID] = userObject.ID
        userDictionary[pagesUpdated]=userObject.pagesUpdated
        userDictionary[topicsUpdated]=userObject.topicsUpdated
        userDictionary[messagesUpdated]=userObject.messageUpdated
        userDictionary[topicMarkersUpdated]=userObject.topicMarkersUpdated
        
        userDefaults.setObject(userDictionary, forKey: lastUser)
        
    }
    
    func fetchLastUser() -> PersistedUser?{
        let userDictionary = userDefaults.objectForKey(lastUser) as? Dictionary<String,AnyObject>
        if let dict = userDictionary {
            let id = dict[ID] as! CKRecordID
            let pages = dict[pagesUpdated] as! NSDate
            let topics = dict[topicsUpdated] as! NSDate
            let messages = dict[messagesUpdated] as! NSDate
            let topicMarkers = dict[topicMarkersUpdated] as! NSDate
            return PersistedUser(id: id, pagesUpdated: pages, topicsUpdated: topics, messageUpdated: messages, topicMarkersUpdated: topicMarkers)
        } else {
            return nil
        }
    }
    
    func generateNewPersistedUser(userID: CKRecordID) -> PersistedUser{
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(0))
        return PersistedUser(id: userID, pagesUpdated: date, topicsUpdated: date, messageUpdated: date, topicMarkersUpdated: date)
    }
    
}

struct PersistedUser {
    let ID: CKRecordID
    var pagesUpdated: NSDate
    var topicsUpdated: NSDate
    var messageUpdated: NSDate
    var topicMarkersUpdated: NSDate
    
    init(id: CKRecordID, pagesUpdated: NSDate, topicsUpdated: NSDate, messageUpdated: NSDate, topicMarkersUpdated: NSDate) {
        self.ID = id
        self.pagesUpdated = pagesUpdated
        self.topicsUpdated = topicsUpdated
        self.messageUpdated = messageUpdated
        self.topicMarkersUpdated = topicMarkersUpdated
    }
    
}
