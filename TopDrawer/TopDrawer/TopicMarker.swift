//
//  TopicMarker.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/1/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

class TopicMarker {
    let page: String?
    let date: NSDate?
    let topicID: String?
    
    init (page: String?, date: NSDate?, topic: String?) {
        self.page = page
        self.date = date
        self.topicID = topic
    }
}
