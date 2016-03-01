//
//  TrayCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import SafariServices

private let reuseIdentifier = "sharedPage"

class TrayCollectionViewController: UICollectionViewController, SFSafariViewControllerDelegate {
    
    var topic: Topic?
    var pages = [Page]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBar = self.tabBarController as! TopicTabBarController
        self.topic = tabBar.topic

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // Do any additional setup after loading the view.
        
        getPages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> SharedPageCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SharedPageCollectionViewCell
    
        // Configure the cell
        
        cell.nameLabel.text = self.pages[indexPath.row].URLString
    
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
        InboxManager.sharedInstance.getPublicTopicPages(self.topic!) { (pages) -> Void in
            self.pages = pages!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
            
        }
    }

}
