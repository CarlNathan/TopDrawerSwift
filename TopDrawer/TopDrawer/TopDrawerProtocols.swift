//
//  TopDrawerProtocols.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

protocol TopDrawerRemoteModifiableObejct {
    func getID()->String
}

protocol TopDrawerPushHandler {
    func handleMessagePush()
    func handleSharedPagePush()
    func handleNewTopicMarkerPush()
    func handleNewTopicPush()
}

protocol PersistedUserManagerProtocol {
    func persistUser(userObject: PersistedUser)
    func wipeUser() -> Void
    func fetchLastUser() -> PersistedUser?
    func generateNewPersistedUser(userID: String) -> PersistedUser
}

protocol PersistedDataSource {
    func wipePersistedData()
    func getPrivatePages()->[Page]
    func getPagesForTopic(topicID: String) -> [Page]
    func getPrivateTopics() -> [Topic]
    func getPublicTopics() -> [Topic]
    func getMessagesAndTopicMarkersForTopic(topicID: String) -> ([TopicMarker],[Message])
    func getPageForID(pageID: String) -> Page
}

protocol FriendManagerProtocol {
    func updateFriendsInMemory()
    func friendForID(id: String) -> Friend?
    func allFriends() -> [Friend]
}

protocol TopDrawerPersistedSavingAssistant {
    func saveMessage(message: Message)
    func saveTopicMarker(topicMarker: TopicMarker)
    func createNewPrivateTopic(topic: Topic)
    func createNewSharedTopic(topic: Topic)
    func assignPageToPrivateTopics(page: Page, topics: [String])
    func createPublicPageEntity(page: Page, topics:[String])
}

protocol TopDrawerRemoteSavingAssistant {
    func saveMessage(message: Message, completion: (Message)->Void)
    func saveTopicMarker(topicMarker: TopicMarker, completion: (TopicMarker)->Void)
    func createNewPrivateTopic(topic: Topic, completion: (Topic)->Void)
    func createNewSharedTopic(topic: Topic, completion: (Topic)->Void)
    func assignPageToPrivateTopics(page: Page, topics: [String], completion: (Page)->Void)
    func assignPageToPublicTopics(page: Page, topics:[String], completion: (Page)->Void)
}

protocol TopDrawerRemoteDeletingService {
    func deletePage(page: Page, completion: (String?)->Void)
    func deletePrivateTopic(topic: Topic, completion: (String?)-> Void)
}

protocol TopDrawerPersistedDeleteService {
    func deletePage(page: Page)
    func deletePrivateTopic(topic: Topic)
    func removeTopicReferencesFromPages(topic: Topic)
}

protocol TopDrawerDataCoordinator {
    func getCurrentUserID (completion: (String)->Void, failed: ()->Void)
    func updateUserDisplayData(image: UIImage, displayName: String)
    func findFriends(completionHandler: () -> Void)
    func fetchUserFromID(recordID: String, completion: ()-> Void)
    func getPublicTopics(completion: ()->Void)
    func getPrivateTopics(completion: ()-> Void)
    func fetchPrivatePages(completion: (PersistedUser) -> Void)
    func getItemsForTopic(topicID: String, completion: ()-> Void)
}

protocol TopDrawerPermissionSubscriptionService {
    func getPermissions(user: PersistedUser, completion: (PersistedUser)->Void, failed: ()->Void)
    func createRemoteTopicSubscription(user: PersistedUser)
    func createSubscriptionsForTopicItems(topicID: String)
    func recievePushNotification(pushInfo: [String:NSObject], completion: ()->Void)
    func createPrivateSubscriptions()
    func recievePrivatePush(pushInfo: [String:NSObject], completion: ()->Void)
}
