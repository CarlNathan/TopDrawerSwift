//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class Page: TopDrawerRemoteModifiableObejct {
    let name: String?
    let description: String?
    let URLString: String?
    var topic: [String]?
    let date: NSDate?
    let image: UIImage?
    var pageID: String!
    let modificationDate: NSDate!
    var isPublic: Bool = false
    
    
    
    init(name: String?, description: String?, URLString: String?, image: UIImage?, date: NSDate?, recordID: String, modifiedDate: NSDate, isPublic: Bool, topics: [String]?) {
        self.name = name
        self.description = description
        self.URLString = URLString
        self.image = image
        self.date = date
        self.pageID = recordID
        self.modificationDate = modifiedDate
        self.isPublic = isPublic
        self.topic = topics
        
    }
    
    func getID()->String {
        return pageID
    }
}


