//
//  GraphDeletService.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class GraphDeletService: TopDrawerPersistedDeleteService {
    
    let graph = Graph()
    
    func deletePage(page: Page) {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: page.pageID)])
        if entities.count > 0 {
            let pageEntity = entities[0]
            pageEntity.delete()
        }
    }
    
    func deletePrivateTopic(topic: Topic) {
        let entities = graph.searchForEntity(types: nil, groups: nil, properties: [(key: "recordID", value: topic.getID())])
        if entities.count > 0 {
            let topicEntity = entities[0]
            topicEntity.delete()
        }
    }
    
    func removeTopicReferencesFromPages(topic: Topic) {
        let entities = graph.searchForEntity(types: [EntityType.PrivatePage.rawValue, EntityType.PrivatePage.rawValue], groups: nil, properties: nil)
        for page in entities {
            if var topicIDStrings = page["topic"] as? [String] {
                if topicIDStrings.count > 0 {
                    for i in 0...topicIDStrings.count - 1 {
                        if topicIDStrings[i] == topic.getID() {
                            topicIDStrings.removeAtIndex(i)
                            page["topic"] = topicIDStrings
                            break
                        }
                    }
                }
            }
        }
    }
}