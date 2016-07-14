//
//  PagesPullTabDataSource.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/14/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class PagesPullTabDataSource: NSObject, PullDownViewDataSource {
    
    var collectionView: UICollectionView
    var topics: [Topic] = [Topic]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        }
    }
    
    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        getTopics()
        setupNotifications()
    }
    
    func getTopics() {
        DataSource.sharedInstance.getPrivateTopics { (fetchedTopics) in
            self.topics = SearchAndSortAssistant().sortTopics(fetchedTopics)
        }
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getTopics), name: "ReloadData", object: nil)
    }
    
    func titleForTabButton() -> String? {
        return "Topics"
    }
    
    func imageForTabButton() -> UIImage? {
        return nil
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PullTopicCell", forIndexPath: indexPath) as! TopicCollectionViewCell
        let topic = topics[indexPath.row]
        cell.configureCell(topic)
        return cell
    }
    
    func cellClassForCollectionView() -> (String, AnyClass?) {
        return ("PullTopicCell", TopicCollectionViewCell.self)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 20
    }
    
}
