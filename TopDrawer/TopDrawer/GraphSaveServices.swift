//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class GraphSaveServices: TopDrawerPersistedSavingAssistant {
    
    lazy var graph: Graph = Graph()
    
    func saveMessage(message: Message) {
        let newMessage = Entity(type: EntityType.Message.rawValue)
        newMessage["body"] = message.body
        newMessage["sender"] = message.sender
        newMessage["topic"] = message.topicRef
        graph.save()
    }
    
    func saveTopicMarker(topicMarker: TopicMarker) {
        let newTopicMarker = Entity(type: EntityType.TopicMarker.rawValue)
        newTopicMarker["date"] = topicMarker.date
        newTopicMarker["page"] = topicMarker.page
        newTopicMarker["topic"] = topicMarker.topicID
        graph.save()
    }
    
    func createNewPrivateTopic(topic: Topic) {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: topic.recordID)])
        if entities.count == 0 {
            let newTopic = Entity(type: EntityType.PrivateTopic.rawValue)
            newTopic["name"] = topic.name
            newTopic["recordID"] = topic.recordID
            graph.save()
        }
    }
    
    func createNewSharedTopic(topic: Topic) {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: topic.recordID)])
        if entities.count == 0 {
            let newTopic = Entity(type: EntityType.PublicTopic.rawValue)
            newTopic["name"] = topic.name
            newTopic["recordID"] = topic.recordID
            graph.save()
        }
    }
    
    func assignPageToPrivateTopics(newPage: Page, topics: [String]) {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: newPage.pageID)])
        let page = entities[0]
        page["topic"] = newPage.topic
        graph.save()
    }
    
    func createPublicPageEntity(page: Page, topics:[String]) {
        let newPage = Entity(type: EntityType.PublicPage.rawValue)
        newPage["name"] = page.name
        newPage["description"] = page.description
        newPage["date"] = page.date
        newPage ["URLString"] = page.URLString
        newPage["image"] = page.image
        newPage["recordID"] = page.pageID
        newPage["modificationDate"] = page.modificationDate
        newPage["isPublic"] = true
        newPage["topic"] = topics
    graph.save()
    }

}
