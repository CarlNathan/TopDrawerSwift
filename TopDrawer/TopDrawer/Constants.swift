//
//  RecordType.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation


public enum RecordType: String {
    case Page = "Page"
    case TopicMarker = "TopicMarker"
    case PrivateTopic = "Topic"
    case PublicTopic = "PublicTopic"
    case Message = "Message"
    case Friend = "Friend"
    case User = "SearchableUser"
}

public enum EntityType: String {
    case PublicPage = "PublicPage"
    case PrivatePage = "PrivatePage"
    case TopicMarker = "TopicMarker"
    case PublicTopic = "PublicTopic"
    case PrivateTopic = "PrivateTopic"
    case Message = "Message"
    case Friend = "Friend"
    case User = "SearchableUser"
}