//
//  TopicSavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "TopicSavedCell"

class TopicSavedPagesCollectionViewController: UICollectionViewController {

    var pages = [Page]()
    var topic: String?
    var topicId: CKRecordID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        downloadTopicId()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if segue.identifier == "showDetail" {
        let senderID = sender as! TopicSavedPageCollectionViewCell
            let detailView = segue.destinationViewController as!DetailViewContoller
            detailView.URLString = senderID.page.URLString
        }
    }
    


    // MARK: UICollectionViewDataSource

    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> TopicSavedPageCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TopicSavedPageCollectionViewCell
    
        // Configure the cell
        cell.page = pages[indexPath.row]
        cell.nameLabel.text = cell.page.URLString
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
    
    func downloadTopicId () {
        
        let privateDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format: "%K = %@", "name", self.topic!)
        let querry = CKQuery(recordType: "Topic", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (topics, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            for topic in topics! {
                
                let ID = topic.recordID
                self.topicId = ID
                
            }
            self.downloadSavedPages()
        }
    }

    func downloadSavedPages () {
        
        let privateDB = CKContainer.defaultContainer().publicCloudDatabase
        let predicate = NSPredicate(format: "%K CONTAINS %@", "topic", self.topicId!)
        
        let querry = CKQuery(recordType: "Page", predicate: predicate)
        privateDB.performQuery(querry, inZoneWithID: nil) { (pages, error) -> Void in
            if let e = error {
                print("failed to load: \(e.localizedDescription)")
                return
            }
            for page in pages! {
                
                //                    let imageAsset = page["image"] as! CKAsset
                //                    let image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
                
                let name = page["name"] as? String ?? nil
                let description = page["description"] as? String ?? nil
                let date = page["date"] as? NSDate ?? nil
                let URLString = page["URLString"] as? String ?? nil
                let newPage = Page(name: name, description: description, URLString: URLString, image: nil, date:  date)
                self.pages.append(newPage)
                
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
                
            })
        }
    }


}
