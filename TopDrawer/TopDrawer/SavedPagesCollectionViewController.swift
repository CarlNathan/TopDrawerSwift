//
//  SavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit
import WebKit

private let reuseIdentifier = "SavedPagesCell"

class SavedPagesCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate {

    var pages = [Page]()
    var senderPage: Page?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSavedPages()
        setupLongPressRecognizer()
        
        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
      override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            let senderID = sender as! SavedPageCollectionViewCell
            let detailView = segue.destinationViewController as!DetailViewContoller
            detailView.URLString = senderID.page.URLString
        }
        if segue.identifier == "privateTopic" {
            let detailView = segue.destinationViewController as! AssignTopicViewController
            detailView.page = self.senderPage
            detailView.isShared = false
        }
        if segue.identifier == "sharedTopic" {
            let detailView = segue.destinationViewController as! AssignTopicViewController
            detailView.page = self.senderPage
            detailView.isShared = true
        }
    }

    // MARK: UICollectionViewDataSource


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> SavedPageCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)as! SavedPageCollectionViewCell
    
        // Configure the cell
            cell.page = pages[indexPath.row]
            cell.nameLabel.text = cell.page.URLString
        
        return cell
    }

    // MARK: UICollectionViewDelegate

            //MARK: Helper
    
    func downloadSavedPages () {
            
            InboxManager.sharedInstance.getPersonalPages { (pages) -> Void in
                self.pages = pages!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView!.reloadData()})
        }
    }
    
        //Mark: - Gesture Actions
    func setupLongPressRecognizer () {
        let longPress = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
        longPress.delegate = self
        longPress.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(longPress)
    }
    
    func handleLongPress (sender: UIGestureRecognizer) {
        let p = sender.locationInView(self.collectionView)
        if let path = self.collectionView?.indexPathForItemAtPoint(p) {
            //assign the cell properties to action
            self.senderPage = self.pages [path.row]
            let alertController = UIAlertController(title: nil, message: "Where would you like to send this page?", preferredStyle: .ActionSheet)
        
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // ... canceled do nothing
            }
            alertController.addAction(cancelAction)
        
            let privateOption = UIAlertAction(title: "Private Topic", style: .Default) { (action) in
                // ... inbox manager add reference to saved page
                self.performSegueWithIdentifier("privateTopic", sender: self)
                // reload data
            }
            alertController.addAction(privateOption)
        
            let sharedOption = UIAlertAction(title: "Shared Topic", style: .Default) { (action) in
                // ... inbox manager add reference to saved page
                self.performSegueWithIdentifier("sharedTopic", sender: self)
                // reaload data
            }
            alertController.addAction(sharedOption)
        
            self.presentViewController(alertController, animated: true) {
                // completion handler
            }
        }
    }
}

