//
//  FriendManager.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

class FriendManager {
    
    private var friends = [String:Friend]()
    private let graph = Graph()
    
    init() {
        updateFriendsInMemory()
    }
    
    private func updateFriendsInMemory(){
        friends = [String:Friend]()
        let entities = graph.searchForEntity(types: [EntityType.Friend.rawValue], groups: nil, properties: nil)
        for friend in entities {
            friends[friend.id] = Friend.friendFomEntity(friend)
        }
    }
    
    func friendForID(id: String) -> Friend? {
        return friends[id]
    }
    
    
    
}
