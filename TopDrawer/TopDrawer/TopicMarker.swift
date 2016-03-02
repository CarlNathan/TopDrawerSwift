//
//  TopicMarker.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/1/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class TopicMarker {
    let page: CKRecordID?
    let date: NSDate?
    let topicID: CKRecordID?
    
    init (page: CKRecordID, date: NSDate, topic: CKRecordID) {
        self.page = page
        self.date = date
        self.topicID = topic
    }
}
