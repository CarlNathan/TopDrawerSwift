//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/26/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

struct Message {
    var sender: Friend!
    var body: String!
    var topicRef: CKRecordID!
    var date: NSDate?

    
    init (sender: Friend, body: String, topic: CKRecordID, date: NSDate) {
        self.sender = sender
        self.body = body
        self.topicRef = topic
        self.date = date
    }
}
