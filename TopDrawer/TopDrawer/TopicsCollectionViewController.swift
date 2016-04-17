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
    
    var topics = [Topic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        collectionView?.alwaysBounceVertical = true
        getTopics()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newTopic), name: "NewTopic", object: nil)

    }
    
    func newTopic(sender:NSNotification) {
        self.topics.append(sender.userInfo!["topic"]as! Topic)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
        
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
        // #warning Incomplete implementation, return the number of items
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
        
        InboxManager.sharedInstance.getTopics {(topics) -> Void in
            self.topics = topics!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
                
            })
        }
    }
    
    @IBAction func newButtonWasPressed(sender: AnyObject) {
        NewTopicPopupVC.presentPopupCV(self)
        
    }
        
}
