//
//  GraphServices.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class GraphServices {
    static let sharedInstance = GraphServices()
    private let graph = Graph()
    
    func wipePersistedData() {
        let entities = graph.searchForEntity()
        for entity in entities {
            entity.delete()
        }
    }
    
    func createEntities(type: RecordType, objects: Array<Dictionary<String, AnyObject>>, groups: [String]?) {
        for dictionary in objects {
            let entity = Entity(type: type.rawValue)
            for entry in dictionary.keys {
                entity[entry] = dictionary[entry]
            }
        }
        graph.save()
    }
}