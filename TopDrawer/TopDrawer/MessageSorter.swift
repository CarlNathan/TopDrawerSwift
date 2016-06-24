//
//  MessageSorter.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/18/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class MessageSorter: NSObject {
    
    
    class func sortMessages (messages:[Message], topicMarkers:[TopicMarker]) -> (Dictionary<String, [Message]>, [TopicMarker]){
        
       
        
        
        var sortedMessages = messages
            sortedMessages.sortInPlace({ (a, b) -> Bool in
                a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
            })
        
        var sortedTopics = topicMarkers
            sortedTopics.sortInPlace({ (a, b) -> Bool in
                a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
            })
        
        if topicMarkers.count == 0 {
            sortedTopics.append(getNilTopicMarker())
            return (["nil": sortedMessages.reverse()], sortedTopics.reverse())
        }
        
        var data = [String: [Message]]()
        
        for topic in sortedTopics {
            var messagesInRange = [Message]()
            for message in sortedMessages {
                if message.date!.compare(topic.date!) == NSComparisonResult.OrderedDescending {
                    messagesInRange.append(message)
                    sortedMessages.removeFirst()
                } else {
                    break
                }
            }
            data[topic.page!] = messagesInRange.reverse()
        }
        
        data["nil"] = sortedMessages.reverse()
        sortedTopics.append(getNilTopicMarker())
        
        
        return (data, sortedTopics.reverse())
    }
    
    class func getNilTopicMarker() -> TopicMarker {
        let nilPage = Page(name: nil, description: nil, URLString: nil, image: nil, date: nil, recordID: "nil", modifiedDate: NSDate(timeIntervalSince1970: NSTimeInterval(0)), isPublic: true, topics: nil)
        let marker = TopicMarker(page: nilPage.pageID, date: NSDate(), topic: "nil")
        return marker
    }
}