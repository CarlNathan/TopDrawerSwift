//
//  CloudKitAbstract.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitAbstract {
    
    //MARK: Create Entities
    
    internal func savePublicRecord(record: CKRecord, completion: (CKRecord)->Void) {
        let publicDB = CKContainer.defaultContainer().publicCloudDatabase
        publicDB.saveRecord(record) { (savedRecord, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
                return
            }
            completion(savedRecord!)
        }
    }
    
    internal func savePrivateRecord(record: CKRecord, completion: (CKRecord)->Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        privateDB.saveRecord(record) { (savedRecord, error) -> Void in
            if let e = error {
                self.provideErrorMessage(e)
                return
            }
            completion(savedRecord!)
        }
    }
    
    // MARK: Perform Cloud Kit Querry
    
    internal func performPublicQuerry(recordType: RecordType, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: ([CKRecord]?)->Void){
        let container = CKContainer.defaultContainer()
        let DB = container.publicCloudDatabase
        let pred = predicate ?? NSPredicate(value: true)
        let querry = CKQuery(recordType: recordType.rawValue, predicate: pred)
        if let sort = sortDescriptors {
            querry.sortDescriptors = sort
        }
        DB.performQuery(querry, inZoneWithID: nil) { (records, error) in
            if let e = error {
                self.provideErrorMessage(e)
                return
            } else {
                completion(records)
            }
        }
    }
    
    internal func performPrivateQuerry(recordType: RecordType, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, completion: ([CKRecord]?)->Void){
        let container = CKContainer.defaultContainer()
        let DB = container.privateCloudDatabase
        let pred = predicate ?? NSPredicate(value: true)
        let querry = CKQuery(recordType: recordType.rawValue, predicate: pred)
        if let sort = sortDescriptors {
            querry.sortDescriptors = sort
        }
        DB.performQuery(querry, inZoneWithID: nil) { (records, error) in
            if let e = error {
                self.provideErrorMessage(e)
                return
            } else {
                completion(records)
            }
        }
    }
    
    
    //MARK: RecordModification
    
    internal func modifyPrivateRecord(object: TopDrawerRemoteModifiableObejct, modifications: (CKRecord)->CKRecord, completion: (CKRecord)->Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let recordID = CKRecordID(recordName: object.getID())
        privateDB.fetchRecordWithID(recordID) { (record, error) in
            if let e = error {
                self.provideErrorMessage(e)
            }
            if let r = record {
                let modifiedRecord = modifications(r)
                self.savePrivateRecord(modifiedRecord, completion: { (record) in
                    if let e = error {
                        self.provideErrorMessage(e)
                    }
                    completion(r)
                })
            }
        }
    }
    
    internal func modifyPublicRecord(object: TopDrawerRemoteModifiableObejct, modifications: (CKRecord)->CKRecord, completion: (CKRecord)->Void) {
            let publicDB = CKContainer.defaultContainer().publicCloudDatabase
            let recordID = CKRecordID(recordName: object.getID())
            publicDB.fetchRecordWithID(recordID) { (record, error) in
                if let e = error {
                    self.provideErrorMessage(e)
                }
                if let r = record {
                    let modifiedRecord = modifications(r)
                    self.savePrivateRecord(modifiedRecord, completion: { (record) in
                        if let e = error {
                            self.provideErrorMessage(e)
                    }
                    completion(r)
                })
            }
        }
    }

    
    //MARK: Delete
    
    internal func deletePrivateRecord(object: TopDrawerRemoteModifiableObejct, completion: (String?)->Void) {
        let privateDB = CKContainer.defaultContainer().privateCloudDatabase
        let record = CKRecordID(recordName: object.getID())
        privateDB.deleteRecordWithID(record) { (recordID, error) in
            if let e = error {
                self.provideErrorMessage(e)
                return
            }
            let name = recordID?.recordName
            completion(name)
        }

    }
    
    internal func deletePublicRecord(object: TopDrawerRemoteModifiableObejct) {
        //not implemented
    }
    
    //MARK: Error Message
    
    internal func provideErrorMessage(error: NSError) {
        print(error.localizedDescription)
    }

}
