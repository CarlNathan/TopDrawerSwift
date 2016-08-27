//
//  GraphEntitySorter.swift
//  TopDrawer
//
//  Created by Carl Udren on 5/16/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Graph

enum SortType {
    case DateOldToNew
    case DateNewToOld
    case AlphabeticalAToZ
    case AlphabeticalZToA
}

class SearchAndSortAssistant {
    
    
    //MARK: Pages
    
    func searchPage(term: String, pages: [Page]) -> [Page] {
        var matches = [Page]()
        for page in pages {
            if page.name!.lowercaseString.containsString(term.lowercaseString) {
                matches.append(page)
            } else if let desc = page.description?.lowercaseString {
                if desc.containsString(term.lowercaseString) {
                    matches.append(page)
                }
            } else if let host = page.hostName?.lowercaseString {
                if host.containsString(term.lowercaseString) {
                    matches.append(page)
                }
            }
        }
        return matches
    }
    func sortPages(type: SortType, pages: [Page]) -> [Page] {
        var sortedPages = pages
        switch type {
        case .DateOldToNew:
            sortedPages.sortInPlace({ (a, b) -> Bool in
                a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
            })
            return sortedPages
        case .AlphabeticalAToZ:
            sortedPages.sortInPlace({ (a, b) -> Bool in
                a.name!.compare(b.name!) == NSComparisonResult.OrderedDescending
            })
            return sortedPages
        case .AlphabeticalZToA:
            sortedPages.sortInPlace({ (a, b) -> Bool in
                a.name!.compare(b.name!) == NSComparisonResult.OrderedAscending
            })
            return sortedPages
        default:
            sortedPages.sortInPlace({ (a, b) -> Bool in
                a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
            })
            return sortedPages
        }
    }
    
    func filterUncatagorizedPages(pages: [Page]) -> [Page] {
        var filteredPages = [Page]()
        for page in pages {
            if let i = page.topic?.count {
                if i == 0 {
                    filteredPages.append(page)
                }
            }
        }
        return filteredPages
    }
    
    func filterRecentPages(pages: [Page]) -> [Page] {
        var filteredPages = [Page]()
        for page in pages {
            if let d = page.date {
                if d > NSDate(timeIntervalSinceNow: -604800) {
                    filteredPages.append(page)
                }
            }
        }
        return filteredPages
    }
    
    //MARK: Topics
    
    func searchTopics(term: String, topics: [Topic]) -> [Topic] {
        var matches = [Topic]()
        for topic in topics {
            if topic.name!.lowercaseString.containsString(term.lowercaseString) {
                matches.append(topic)
            }
        }
        return matches
    }
    
    func sortTopics(topics: [Topic]) -> [Topic] {
        var sortedTopics = topics
        sortedTopics.sortInPlace({ (a, b) -> Bool in
                a.name!.compare(b.name!) == NSComparisonResult.OrderedAscending
            })
        return sortedTopics
        }
    
    //MARK: Friends
    
    func searchFriends() {
        
    }
    
    func sortFriends(friends: [Friend]) -> [Friend] {
        var sortedFriends = friends
        sortedFriends.sortInPlace { (a, b) -> Bool in
            a.familyName!.compare(b.familyName!) == NSComparisonResult.OrderedDescending
        }
        return sortedFriends
    }
    
}
