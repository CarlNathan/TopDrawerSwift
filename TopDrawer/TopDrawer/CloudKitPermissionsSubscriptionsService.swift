//
//  CloudKitPermissionsSubscriptionsService.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitPermissionsSubscriptionsService: CloudKitAbstract, TopDrawerPermissionSubscriptionService {
    
    //MARK: Permissions
    
    func getPermissions(user: PersistedUser, completion: (PersistedUser)->Void, failed: ()->Void) {
        var updatedUser = user
        CKContainer.defaultContainer().requestApplicationPermission(CKApplicationPermissions.UserDiscoverability, completionHandler: { applicationPermissionStatus, error in
            if let e = error {
                self.provideErrorMessage(e)
                return
            }
            if applicationPermissionStatus == CKApplicationPermissionStatus.Granted {
                updatedUser.markPermissionsGranted()
                completion(updatedUser)
            } else {
                failed()
            }
        })
    }

    //MARK: Subscriptions
    
    func createRemoteTopicSubscription(user: PersistedUser) {
        let predicate = NSPredicate(format: "%K CONTAINS %@" , "users", CKRecordID(recordName: user.ID))
        
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.alertBody = "New Topic"
        
        createPublicPushSubscription(RecordType.PublicTopic, predicate: predicate, notificationInfo: notificationInfo) { (subscription) in
            print(subscription)
        }
    }
    
    func createSubscriptionsForTopicItems(topicID: String) {
        let recordID = CKRecordID(recordName: topicID)
        
        let messageRef = CKReference(recordID: recordID, action: .None)
        let messagePredicate = NSPredicate(format: "%K CONTAINS %@" , "topic", [messageRef])
        let pageRef = CKReference(recordID: recordID, action: .None)
        let pagePredicate = NSPredicate(format: "%K CONTAINS %@", "topic", [pageRef])
        let markerRef = CKReference(recordID: recordID, action: .None)
        let markerPredicate = NSPredicate(format: "%K = %@" , "topic", markerRef)
        
        let messageNotificationInfo = CKNotificationInfo()
        messageNotificationInfo.shouldBadge = true
        messageNotificationInfo.shouldSendContentAvailable = true
        messageNotificationInfo.alertBody = "New Message"
        
        let pageNotificationInfo = CKNotificationInfo()
        pageNotificationInfo.shouldBadge = true
        pageNotificationInfo.shouldSendContentAvailable = true
        pageNotificationInfo.alertBody = "New Page"
        
        let markerNotificationInfo = CKNotificationInfo()
        markerNotificationInfo.shouldBadge = true
        markerNotificationInfo.shouldSendContentAvailable = true
        markerNotificationInfo.alertBody = "New Marker"
        
        createPublicPushSubscription(RecordType.Message, predicate: messagePredicate, notificationInfo: messageNotificationInfo) { (messageSubscription) in
            print(messageSubscription)
        }
        
        createPublicPushSubscription(RecordType.Page, predicate: pagePredicate, notificationInfo: pageNotificationInfo) { (pageSubscription) in
            print(pageSubscription)
        }
        
        createPublicPushSubscription(RecordType.TopicMarker, predicate: markerPredicate, notificationInfo: markerNotificationInfo) { (markerSubscription) in
            print(markerSubscription)
        }
    }
    
    
    private func createPublicPushSubscription(recordType: RecordType, predicate: NSPredicate, notificationInfo: CKNotificationInfo, completion: (CKSubscription?)->Void){
        let DB = CKContainer.defaultContainer().publicCloudDatabase
        let subscription = CKSubscription(recordType: recordType.rawValue, predicate: predicate, options: .FiresOnRecordCreation)
        subscription.notificationInfo = notificationInfo
        DB.saveSubscription(subscription) { (savedSubscription, error) in
            if let e = error {
                self.provideErrorMessage(e)
            } else {
                completion(savedSubscription)
            }
        }
    }
    
    //MARK: recievePush 
    
    func recievePushNotification(pushInfo: [String:NSObject], completion: ()->Void) {
        
        let notification = CKNotification(fromRemoteNotificationDictionary: pushInfo)
        let alertBody = notification.alertBody
        
        print(alertBody)
        if let queryNotification = notification as? CKQueryNotification {
            let recordID = queryNotification.recordID
            guard let body = queryNotification.alertBody else {
                return
            }
            
            if let ID = recordID {
                switch body {
                case "New Topic":
                    DataCoordinatorInterface.sharedInstance.getPublicTopics({
                        completion()
                    })
                    PushInterface.sharedInstance.createSubscriptionsForTopicItems(ID.recordName)
                    break
                case "New Page":
                    DataCoordinatorInterface.sharedInstance.fetchItemsForTopic(ID.recordName, completion: {
                        completion()
                    })
                    break
                case "New Message":
                    DataCoordinatorInterface.sharedInstance.fetchItemsForTopic(ID.recordName, completion: {
                        completion()
                    })
                    break
                case "New Marker":
                    DataCoordinatorInterface.sharedInstance.fetchItemsForTopic(ID.recordName, completion: {
                        completion()
                    })
                    break
                default:
                    return
                }
            }
        }
    }
    
}


