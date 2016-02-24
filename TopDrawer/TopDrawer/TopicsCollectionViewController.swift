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
    
    var topics = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        downloadTopics()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowTopic" {
            let senderID = sender as! TopicCollectionViewCell
            let topicPageView = segue.destinationViewController as!TopicSavedPagesCollectionViewController
            topicPageView.topic = senderID.topic
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
        cell.topicLabel.text = cell.topic
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    func downloadTopics () {
        
        let privateDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let querry = CKQuery(recordType: "Topic", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (Topics, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            for topic in Topics! {
                
                //                    let imageAsset = page["image"] as! CKAsset
                //                    let image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
                
                let name = topic["name"] as? String ?? nil
                self.topics.append(name!)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
                
            })
        }
    }

}
