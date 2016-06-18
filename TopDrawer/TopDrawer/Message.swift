//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/26/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

class Message {
    var sender: String?
    var body: String?
    var topicRef: String?
    var date: NSDate?

    
    init (sender: String?, body: String?, topic: String?, date: NSDate?) {
        self.sender = sender
        self.body = body
        self.topicRef = topic
        self.date = date
    }
}
