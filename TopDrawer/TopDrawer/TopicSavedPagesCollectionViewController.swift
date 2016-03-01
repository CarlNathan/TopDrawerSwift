//
//  TopicSavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit
import SafariServices

private let reuseIdentifier = "TopicSavedCell"

class TopicSavedPagesCollectionViewController: UICollectionViewController, SFSafariViewControllerDelegate {

    var pages = [Page]()
    var topic: Topic?
    var topicId: CKRecordID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        getPages()
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

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let URLString = pages[indexPath.row].URLString
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    
    
    func getPages () {
        InboxManager.sharedInstance.getPagesForTopic(self.topic!) { (pages) -> Void in
            self.pages = pages!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
                
            })

        }
    }


}
