//
//  TrayCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import SafariServices
import CloudKit

private let reuseIdentifier = "sharedPage"

class TrayCollectionViewController: UICollectionViewController, SFSafariViewControllerDelegate {
    
    var topic: Topic?
    var pages = [Page]() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TopicTabBarController
        self.topic = tabBar.topic

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // Do any additional setup after loading the view.
        
        getPages()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getPages), name: "ReloadData", object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> SharedPageCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SharedPageCollectionViewCell
    
        // Configure the cell
        cell.page = self.pages[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height = CGFloat(150.0)
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
        DataSource.sharedInstance.getPagesForTopic(topic!.recordID!) { (pages) in
            self.pages = SearchAndSortAssistant().sortPages(SortType.DateNewToOld, pages: pages)
        }
    }

}
