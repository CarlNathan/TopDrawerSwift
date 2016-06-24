//
//  SavingInterface.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/21/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation


class SavingInterface: ThreadingManager {
    
    static let sharedInstance = SavingInterface()
    let writer: TopDrawerPersistedSavingAssistant = GraphSaveServices()
    let remote: TopDrawerRemoteSavingAssistant = CloudKitSavingServices()
    
    func saveMessage(message: Message) {
        //cloudkit save message
        remote.saveMessage(message, completion: { (savedMessage) in
                //
            })
        //update in UI
    }
    
    func saveTopicMarker(topicMarker: TopicMarker) {
        //cloudkit save topicmarker
        remote.saveTopicMarker(topicMarker) { (savedTopicMarker) in
            //
        }
        //update in UI
    }
    
    func createNewPrivateTopic(topic: Topic) {
        //cloudkit savePrivateTopic
        remote.createNewPrivateTopic(topic) { (savedTopic) in
            self.writer.createNewPrivateTopic(savedTopic)
        }
        //graph save
    }
    
    func createNewSharedTopic(topic: Topic, completion: (Topic)->Void) {
        //cloudkit saveSharedTopic
        remote.createNewSharedTopic(topic) { (savedTopic) in
            self.writer.createNewSharedTopic(savedTopic)
            completion(savedTopic)
        }
        //graphsave
    }
    
    func assignPageToPrivateTopics(page: Page, topics: [String]) {
        //cloudkit assign to topics
        remote.assignPageToPrivateTopics(page, topics: topics) { (savedPage) in
            //dont wait for completion
        }
        writer.assignPageToPrivateTopics(page, topics: topics)
        //graphsave update
    }
    
    func assignPageToPublicTopics(page: Page, topics:[String]) {
        //cloudkit assign to topics
        remote.assignPageToPublicTopics(page, topics: topics) { (savedPage) in
            //no need to wait for savedPage
        }
        writer.createPublicPageEntity(page, topics: topics)
        //create new page
    }
}
