//
//  PersistedUserManager.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

class PersistedUserManager: PersistedUserManagerProtocol {
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    //Constants
    let ID = "ID"
    let privatePagesUpdated = "privatePagesUpdated"
    let publicPagesUpdated = "publicPagesUpdated"
    let publicTopicsUpdated = "publicTopicsUpdated"
    let privateTopicsUpdated = "privateTopicsUpdated"
    let messagesUpdated = "messagesUpdated"
    let topicMarkersUpdated = "topicMarkersUpdated"
    let lastUser = "LastUser"
    let PermissionsGranted = "PermissionsGranted"

    func persistUser(userObject: PersistedUser){
        var userDictionary = Dictionary<String, AnyObject>()
        userDictionary[ID] = userObject.ID
        userDictionary[privatePagesUpdated] = userObject.privatePagesUpdated
        userDictionary[publicPagesUpdated] = userObject.publicPagesUpdated
        userDictionary[publicTopicsUpdated] = userObject.publicTopicsUpdated
        userDictionary[privateTopicsUpdated] = userObject.privateTopicsUpdated
        userDictionary[messagesUpdated] = userObject.messageUpdated
        userDictionary[topicMarkersUpdated] = userObject.topicMarkersUpdated
        
        userDefaults.setObject(userDictionary, forKey: lastUser)
        
    }
    
    func wipeUser() -> Void {
        userDefaults.removeObjectForKey(lastUser)
    }
    
    func fetchLastUser() -> PersistedUser?{
        let userDictionary = userDefaults.objectForKey(lastUser) as? Dictionary<String,AnyObject>
        if let dict = userDictionary {
            let id = dict[ID] as! String
            let publicPages = dict[publicPagesUpdated] as! NSDate
            let privatePages = dict[privatePagesUpdated] as! NSDate
            let publicTopics = dict[publicTopicsUpdated] as! NSDate
            let privateTopics = dict[privateTopicsUpdated] as! NSDate
            let messages = dict[messagesUpdated] as! NSDate
            let topicMarkers = dict[topicMarkersUpdated] as! NSDate
            let permissions = dict[PermissionsGranted] as! Bool
            return PersistedUser(id: id, publicPagesUpdated: publicPages, privatePagesUpdated: privatePages, publicTopicsUpdated: publicTopics, privateTopicsUpdated: privateTopics, messageUpdated: messages, topicMarkersUpdated: topicMarkers, permissionsGranted: permissions)
        } else {
            return nil
        }
    }
    
    func generateNewPersistedUser(userID: String) -> PersistedUser{
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(0))
        return PersistedUser(id: userID, publicPagesUpdated: date, privatePagesUpdated: date, publicTopicsUpdated: date, privateTopicsUpdated: date, messageUpdated: date, topicMarkersUpdated: date, permissionsGranted: false)
    }
    
}

struct PersistedUser {
    let ID: String
    var privatePagesUpdated: NSDate
    var publicTopicsUpdated: NSDate
    var privateTopicsUpdated: NSDate
    var messageUpdated: NSDate
    var topicMarkersUpdated: NSDate
    var publicPagesUpdated: NSDate
    var permissionsGranted: Bool
    
    init(id: String, publicPagesUpdated: NSDate, privatePagesUpdated: NSDate, publicTopicsUpdated: NSDate, privateTopicsUpdated: NSDate, messageUpdated: NSDate, topicMarkersUpdated: NSDate, permissionsGranted: Bool) {
        self.ID = id
        self.privatePagesUpdated = privatePagesUpdated
        self.publicPagesUpdated = publicPagesUpdated
        self.publicTopicsUpdated = publicTopicsUpdated
        self.privateTopicsUpdated = privateTopicsUpdated
        self.messageUpdated = messageUpdated
        self.topicMarkersUpdated = topicMarkersUpdated
        self.permissionsGranted = permissionsGranted
    }
    
    mutating func markPermissionsGranted() {
        permissionsGranted = true
    }
    
}
