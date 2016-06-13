//
//  GraphEntitySorter.swift
//  TopDrawer
//
//  Created by Carl Udren on 5/16/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class SearchAndSortAssistant {
    
    let graph = Graph()
    
    func searchForSavedPages(completion: ([Page])->Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let entities = self.graph.searchForEntity(types: ["Page"], groups: nil, properties: nil)
            var pages = [Page]()
            for page in entities {
                pages.append(Page.pageFromEntity(page))
            }
            dispatch_async(dispatch_get_main_queue(), {
                completion(pages)
            })
        }
    }
    
    
}
