//
//  DataSource.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/18/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation


class DataSource: ThreadingManager {
    
    static let sharedInstance = DataSource()
    
    private let reader: PersistedDataSource = GraphServices()
    private let friendManager: FriendManagerProtocol = FriendManager()
    
    func wipePersistedData(completion: ()->Void) {
        runInBackgroundThread {
            self.reader.wipePersistedData()
            self.runInMainThread(completion)
        }
    }
    
    func getPrivatePages(completion: ([Page])->Void) {
        runInBackgroundThread {
            let pages = self.reader.getPrivatePages()
            self.runInMainThread({completion(pages)})
        }
    }
    
    func getPagesForTopic(topicID: String, completion: ([Page])->Void) {
        runInBackgroundThread {
            let pages = self.reader.getPagesForTopic(topicID)
            self.runInMainThread({
                completion(pages)
            })
        }
    }
    
    func getPageForID(pageID: String, completion: (Page)->Void) {
        runInBackgroundThread {
            let page = self.reader.getPageForID(pageID)
            self.runInMainThread({
                completion(page)
            })
        }
    }
    
    func getPrivateTopics(completion: ([Topic])->Void) {
        runInBackgroundThread {
            let topics = self.reader.getPrivateTopics()
            self.runInMainThread({
                completion(topics)
            })
        }
    }

    func getPublicTopics(completion: ([Topic])->Void) {
        runInBackgroundThread {
            let topics = self.reader.getPublicTopics()
            self.runInMainThread({
                completion(topics)
            })
        }
    }
    
    func getMessagesAndTopicMarkersForTopic(topicID: String, completion: ([TopicMarker],[Message])->Void) {
        runInBackgroundThread {
            let (topicMarkers, messages) = self.reader.getMessagesAndTopicMarkersForTopic(topicID)
            self.runInMainThread({
                completion(topicMarkers,messages)
            })
        }
    }
    
    //MARK: FriendManager
    func updateFriends() {
        friendManager.updateFriendsInMemory()
    }
    
    func friendForID(id: String) -> Friend? {
        return friendManager.friendForID(id)
    }
    func allFriends() -> [Friend] {
        return friendManager.allFriends()
    }
    
}