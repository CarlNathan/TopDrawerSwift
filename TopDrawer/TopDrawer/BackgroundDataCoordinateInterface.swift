//
//  DataCoordinateInterface.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class DataCoordinatorInterface {
    
    static let sharedInstance = DataCoordinatorInterface()
    private let fetch: TopDrawerDataCoordinator = CloudKitGraphCoordinator()
    private let localDelete: TopDrawerPersistedDeleteService = GraphDeletService()
    private let remoteDelete: TopDrawerRemoteDeletingService = CloudKitDeletingService()
    private let permissionSubscription: TopDrawerPermissionSubscriptionService = CloudKitPermissionsSubscriptionsService()
    
    var user: PersistedUser? {
        didSet {
            fetch.setUser(self.user)
        }
    }
    private let userManager: PersistedUserManagerProtocol = PersistedUserManager()

    func updateUser(user: PersistedUser) {
        userManager.persistUser(user)
    }
    
    func startupSequence() {
        signIn {
            //once we have user
            
            //check onboarding seen
                //launch onboarding checkUser for seen onboarding
                    //register for push
                    //searchability
            
            //1. GetFriends
            //2. Get Pages
            //3. Get Topics
            
            self.fetch.findFriends({
                DataSource.sharedInstance.updateFriends()
            })
            self.fetch.getPublicTopics({
                // subscribe to these topics
            })
            self.fetch.getPrivateTopics({
                //
            })
            self.fetch.fetchPrivatePages({ (updatedUser) in
                self.userManager.persistUser(updatedUser)
            })
        }
    }
    
    private func signIn(completion: ()->Void) {
        user = userManager.fetchLastUser()
        fetch.getCurrentUserID({ userID in
            if self.user == nil {
                self.user = self.userManager.generateNewPersistedUser(userID)
                self.userManager.persistUser(self.user!)
            }
            if userID != self.user!.ID {
                DataSource.sharedInstance.wipePersistedData({
                    self.user = self.userManager.generateNewPersistedUser(userID)
                    self.userManager.persistUser(self.user!)
                })
            }
            completion()
        }) {
            //failed to get user: FIX ME: prompt sign in
        }
    }


    
    //MARK: Deleting
    
    func deletePage(page: Page) {
        remoteDelete.deletePage(page) { (pageID) in
            self.localDelete.deletePage(page)
        }
    }
    
    //MARK: Background Fetching
    
    func updateUserDisplayData(image: UIImage, displayName: String) {
        fetch.updateUserDisplayData(image, displayName: displayName)
    }
    
    
    func fetchUnknownUserFromID(recordID: String, completion: ()-> Void) {
        fetch.fetchUserFromID(recordID) { 
            //do something when searchable user found
        }
    }
    
    func getPublicTopics(completion: ()->Void) {
        fetch.getPublicTopics {
            //done fetching
        }
    }
    
    func getPrivateTopics(completion: ()-> Void) {
        fetch.getPrivateTopics {
            //done fetching
        }
    }
    func fetchPrivatePages(completion: (PersistedUser) -> Void) {
        fetch.fetchPrivatePages { (updatedUser) in
            self.userManager.persistUser(updatedUser)
        }
    }
    
    func fetchItemsForTopic(topicID: String, completion: ()->Void) {
        fetch.getItemsForTopic(topicID) { 
            completion()
        }
    }
   
}
