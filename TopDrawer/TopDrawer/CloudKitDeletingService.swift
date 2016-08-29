//
//  CloudKitDeletingService.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitDeletingService: CloudKitAbstract, TopDrawerRemoteDeletingService {
    
    func deletePage(page: Page, completion: (String?) -> Void) {
        deletePrivateRecord(page) { (pageID) in
            completion(pageID)
        }
    }
        
    func deletePrivateTopic(topic: Topic, completion: (String?) -> Void) {
        deletePrivateRecord(topic) { (topicID) in
            completion(topicID)
        }
    }
}
