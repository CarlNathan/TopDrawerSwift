//
//  GraphServices.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class GraphServices: PersistedDataSource {
    private let graph = Graph()
    
    func wipePersistedData() {
        let entities = graph.searchForEntity(types:[EntityType.Friend.rawValue, EntityType.Message.rawValue,EntityType.PublicPage.rawValue,EntityType.PrivatePage.rawValue,EntityType.PrivateTopic.rawValue, EntityType.PublicTopic.rawValue, EntityType.TopicMarker.rawValue, EntityType.User.rawValue])
        for entity in entities {
            entity.delete()
        }
    }
    
    //MARK: Pages
    
    func getPrivatePages()->[Page] {
        let entities = graph.searchForEntity(types: [EntityType.PrivatePage.rawValue], groups: nil, properties: nil)
        var pages = [Page]()
        for entity in entities {
            pages.append(Page.pageFromEntity(entity))
        }
        return pages
    }
    
    func getPagesForTopic(topicID: String) -> [Page] {
        var pages = [Page]()
        let entities = graph.searchForEntity(types: [EntityType.PublicPage.rawValue, EntityType.PrivatePage.rawValue], groups: nil, properties: nil)
        for entity in entities {
            if let topicIDStrings = entity["topic"] as? [String] {
                for IDString in topicIDStrings {
                    if IDString == topicID {
                        pages.append(Page.pageFromEntity(entity))
                    }
                }
            }
        }
        return pages
    }
    
    func getPageForID(pageID: String) -> Page {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: pageID)])
        return Page.pageFromEntity(entities.first!)
    }
    
    //MARK: Topics
    
    func getPrivateTopics() -> [Topic] {
        let entities = graph.searchForEntity(types: [EntityType.PrivateTopic.rawValue])
        var topics = [Topic]()
        for entity in entities {
            topics.append(Topic.topicFromEntity(entity))
        }
        return topics
    }
    
    func getPublicTopics() -> [Topic] {
        let entities = graph.searchForEntity(types: [EntityType.PublicTopic.rawValue])
        var topics = [Topic]()
        for entity in entities {
            topics.append(Topic.topicFromEntity(entity))
        }
        return topics
    }
    
    //MARK: Messages
    
    private func getMessagesForTopic(topicID: String) -> [Message] {
        let entities = graph.searchForEntity(types: [EntityType.Message.rawValue], groups: nil, properties: nil)
        var messages = [Message]()
        for entity in entities {
            if entity["topic"] as? String == topicID {
                messages.append(Message.messageFromEntity(entity))
            }
        }
        return messages
    }
    
    //MARK: Topic Markers
    
    private func getTopicMarkersForTopic(topicID: String) -> [TopicMarker] {
        let entities = graph.searchForEntity(types: [EntityType.TopicMarker.rawValue], groups: nil, properties: nil)
        var topicMarkers = [TopicMarker]()
        for entity in entities {
            if entity["topic"] as? String == topicID {
                topicMarkers.append(TopicMarker.topicMarkerFromEntity(entity))
            }
        }
        return topicMarkers
    }
    
    //MARK: Topic Markers and Messages
    
    func getMessagesAndTopicMarkersForTopic(topicID: String) -> ([TopicMarker],[Message]) {
        let messages = getMessagesForTopic(topicID)
        let topicMarkers = getTopicMarkersForTopic(topicID)
        return (topicMarkers,messages)
    }
}