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

    var pages = [Page]() {
        didSet{
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView!.reloadData()
                
            })
        }
    }
    var topic: Topic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        collectionView?.alwaysBounceVertical = true
        getPages()
        title = topic!.name
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height = CGFloat(200.0)
        return CGSizeMake(width, height)
    }


    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let URLString = pages[indexPath.row].URLString
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    
    
    func getPages () {
        DataSource.sharedInstance.getPagesForTopic(topic!.recordID!) { (fetchedPages) in
            self.pages = fetchedPages
        }
    }


}
