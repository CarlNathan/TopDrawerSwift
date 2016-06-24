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
}