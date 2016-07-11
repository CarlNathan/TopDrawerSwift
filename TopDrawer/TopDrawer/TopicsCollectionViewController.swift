//
//  TopicsCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "TopicCell"

class TopicsCollectionViewController: UICollectionViewController {
    
    var topics = [Topic]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.alwaysBounceVertical = true
        getTopics()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getTopics), name: "ReloadData", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        getTopics()
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowTopic" {
            let senderID = sender as! TopicCollectionViewCell
            let topicPageView = segue.destinationViewController as!TopicSavedPagesCollectionViewController
            topicPageView.topic = senderID.topic
        } else if segue.identifier == "newTopic" {
            // perform new topic task
        }
    }

    // MARK: UICollectionViewDataSource


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> TopicCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TopicCollectionViewCell
    
        // Configure the cell
        cell.topic = topics[indexPath.row]
        cell.topicLabel.text = cell.topic!.name
        return cell
    }

    func getTopics () {
        
        DataSource.sharedInstance.getPrivateTopics { (fetchedTopics) in
            self.topics = SearchAndSortAssistant().sortTopics(fetchedTopics)
            
        }
    }
    
    @IBAction func newButtonWasPressed(sender: AnyObject) {
        NewTopicPopupVC.presentPopupCV(self)
        
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        //implement some dynamic scrolling animation
    }
        
}
