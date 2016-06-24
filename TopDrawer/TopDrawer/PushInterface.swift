//
//  PushInterface.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

class PushInterface {
    
    static let sharedInstance = PushInterface()
    
    private let permissionSubscription: TopDrawerPermissionSubscriptionService = CloudKitPermissionsSubscriptionsService()

    
    //MARK: Supscriptions
    
    func getPermissions(user: PersistedUser, completion: (PersistedUser)->Void, failed: ()->Void) {
        permissionSubscription.getPermissions(user, completion: { (updatedUser) in
            //worked
            DataCoordinatorInterface.sharedInstance.updateUser(updatedUser)
        }) {
            //failed
        }
    }
    
    func createRemoteTopicSubscription(user: PersistedUser) {
        permissionSubscription.createRemoteTopicSubscription(user)
    }
    
    func createSubscriptionsForTopicItems(topicID: String) {
        permissionSubscription.createSubscriptionsForTopicItems(topicID)
    }
    
    //MARK: Handle Push
    
    func handlePush(didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if let pushInfo = userInfo as? [String: NSObject] {
            permissionSubscription.recievePushNotification(pushInfo, completion: {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "ReloadData", object: self, userInfo: [:]))
            })
        }
    }

}
