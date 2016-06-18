//
//  DataSource.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/18/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

protocol PersistedDataSource {
    func wipePersistedData()
    func getPrivatePages()->[Page]
    func getPagesForTopic(topicID: String) -> [Page]
    func getPrivateTopics() -> [Topic]
    func getPublicTopics() -> [Topic] 
    func getMessagesAndTopicMarkersForTopic(topicID: String) -> ([TopicMarker],[Message])
}

class DataSource {
    
    static let sharedInstance = DataSource()
    
    private let reader: PersistedDataSource = GraphServices()
    
    private func runInBackgroundThread(block: ()->Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            block()
        }
    }
    
    func wipePersistedData(completion: ()->Void) {
        runInBackgroundThread {
            reader.wipePersistedData()
            dispatch_async(dispatch_get_main_queue(), {
                completion()
            })
        }
    }
    
    func getPrivatePages(completion: ([Page])->Void) {
        runInBackgroundThread {
            let pages = reader.getPrivatePages()
            dispatch_async(dispatch_get_main_queue(), {
                completion(pages)
            })
        }
    }
    
    func getPagesForTopic(topicID: String, completion: ([Page])->Void) {
        runInBackgroundThread {
            let pages = reader.getPagesForTopic(topicID)
            dispatch_async(dispatch_get_main_queue(), {
                completion(pages)
            })
        }
    }
    
    func getPrivateTopics(completion: ([Topic])->Void) {
        runInBackgroundThread {
            let topics = reader.getPrivateTopics()
            dispatch_async(dispatch_get_main_queue(), {
                completion(topics)
            })
        }
    }

    func getPublicTopics(completion: ([Topic])->Void) {
        runInBackgroundThread {
            let topics = reader.getPrivateTopics()
            dispatch_async(dispatch_get_main_queue(), {
                completion(topics)
            })
        }
    }
    
    func getMessagesAndTopicMarkersForTopic(topicID: String, completion: ([TopicMarker],[Message])->Void) {
        runInBackgroundThread {
            let (topicMarkers, messages) = reader.getMessagesAndTopicMarkersForTopic(topicID)
            dispatch_async(dispatch_get_main_queue(), {
                completion(topicMarkers,messages)
            })
        }
    }


    
}