//
//  PagesPullTabDataSource.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/14/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class PagesPullTabDataSource: NSObject, PullDownViewDataSource {
    
    var collectionView: UICollectionView
    var topics: [Topic] = [Topic]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView.reloadData()
            }
        }
    }
    var editEnabled: Bool = false {
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
    
    func imageForTabButton() -> UIImage? {
        return nil
    }
    
    func editButtonPressed(enabled: Bool) {
        editEnabled = enabled
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count + 3
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PullTopicCell", forIndexPath: indexPath) as! TopicCollectionViewCell
        cell.cellDelegate = self
        if editEnabled {
            cell.editEnabled = true
        } else {
            cell.editEnabled = false
        }
        if indexPath.row == 0 {
            cell.topicLabel.text = "All Pages"
            cell.backgroundColor = MaterialColor.grey.base.colorWithAlphaComponent(0.3)
            cell.editEnabled = false
            return cell
        } else if indexPath.row == 1 {
            cell.topicLabel.text = "Recently Added"
            cell.backgroundColor = MaterialColor.grey.base.colorWithAlphaComponent(0.3)
            cell.editEnabled = false
            return cell
        } else if indexPath.row == 2 {
            cell.topicLabel.text = "Uncatagorized"
            cell.backgroundColor = MaterialColor.grey.base.colorWithAlphaComponent(0.3)
            cell.editEnabled = false
            return cell
        } else {
            let topic = topics[indexPath.row - 3]
            cell.configureCell(topic)
            return cell
        }
    }
        
    func cellClassForCollectionView() -> (String, AnyClass?) {
        return ("PullTopicCell", TopicCollectionViewCell.self)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 10
    }
}

extension PagesPullTabDataSource: TopicCollectionViewCellDelegate {
    func deleteButtonPressed(topic: Topic) {
        //delete topic
        DataCoordinatorInterface.sharedInstance.deletePrivateTopic(topic) { 
            self.getTopics()
        }
    }
}

