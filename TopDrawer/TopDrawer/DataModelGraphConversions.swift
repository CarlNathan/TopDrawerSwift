//
//  DataModelGraphConversions.swift
//  TopDrawer
//
//  Created by Carl Udren on 5/16/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph
import CloudKit

extension Page {
    class func pageFromEntity(entity: Entity) -> Page {
        
        let image = entity["image"] as? UIImage ?? nil
        let name = entity["name"] as? String ?? nil
        let description = entity["description"] as? String ?? nil
        let date = entity["date"] as? NSDate ?? nil
        let URLString = entity["URLString"] as? String ?? nil
        let id = entity["recordID"] as! CKRecordID
        let modifiedDate = entity["modificationDate"] as? NSDate
        let newPage = Page(name: name, description: description, URLString: URLString, image: image, date: date, recordID: id, modifiedDate: modifiedDate!)
        
        return newPage
        
    }
}
