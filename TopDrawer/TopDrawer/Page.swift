//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class Page {
    let name: String?
    let description: String?
    let URLString: String?
    var topic: [CKReference]?
    let date: NSDate?
    let image: UIImage?
    let pageID: CKRecordID
    
    
    
    init(name: String?, description: String?, URLString: String?, image: UIImage?, date: NSDate?, recordID: CKRecordID) {
        self.name = name
        self.description = description
        self.URLString = URLString
        self.image = image
        self.date = date
        self.pageID = recordID
        
    }
    
    func assignTopic (topics: [String]) {
        
    }
    
}


extension Page {
    
    func saveToCloudKit() {
        
        let pageID = CKRecordID(recordName: self.name!)
        let pageRecord = CKRecord(recordType: "Page", recordID: pageID)
        
        pageRecord["description"] = self.description
        pageRecord["date"] = self.date
        pageRecord["URLString"] = URLString
        if let topic = self.topic {
            pageRecord["Topic"] = topic

        }
        
        let data = UIImagePNGRepresentation(self.image!)
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let path = directory.path! + "/\(self.name).png"
        data!.writeToFile(path, atomically: false)
        pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        
        let dataBase = CKContainer.defaultContainer().privateCloudDatabase
        dataBase.saveRecord(pageRecord) { (record, error) -> Void in
            if let e = error {
                print("Error Saving Meal: \(e.localizedDescription)")
                return
            }
            do{
            try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch _ {
                //handle error
            }
            
        }
    }
}
