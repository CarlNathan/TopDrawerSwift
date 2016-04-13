//
//  SavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit
import SafariServices
import Material

private let reuseIdentifier = "SavedPagesCell"

class SavedPagesCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate, SFSafariViewControllerDelegate, CellCardViewDelegate {

    var pages = [Page]() {
        didSet{
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.loadLayer.removeFromSuperlayer()
                self.loadLayer.removeAllAnimations()
                self.collectionView?.reloadData()
            }
        }
    }
    var senderPage: Page?
    let loadLayer = MaterialLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingCircle()
        downloadSavedPages()
        setupLongPressRecognizer()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SavedPagesCollectionViewController.newPage(_:)), name: "SavedNewPersonalPage", object: nil)
        
        // Do any additional setup after loading the view.
        
    }
    
    func setupLoadingCircle() {
        loadLayer.image = UIImage(named: "Loading Circle")
        loadLayer.frame = CGRectMake(view.center.x - 50 , view.center.y - 50, 100, 100)
        view.layer.addSublayer(loadLayer)
        
        let fullRotation = CABasicAnimation(keyPath: "transform.rotation")
        fullRotation.fromValue = 0
        fullRotation.toValue = -((360*M_PI)/180)
        fullRotation.duration = 2
        fullRotation.repeatCount = 1e100
        
        loadLayer.animate(fullRotation)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        downloadSavedPages()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func newPage(sender:NSNotification) {
        let record = sender.userInfo!["page"] as! CKRecord
        let page = InboxManager.sharedInstance.pageFromCKRecord(record)
        pages.append(page)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.collectionView?.reloadData()
        })
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
            cell.cardView.cardDelegate = self
            cell.page = pages[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height = CGFloat(300.0)
        return CGSizeMake(width, height)
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let URLString = pages[indexPath.row].URLString
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    

            //MARK: Helper
    
    func downloadSavedPages () {
            
            InboxManager.sharedInstance.getPersonalPages { (pages) -> Void in
                var newPages = pages!
                
                newPages.sortInPlace({ (a, b) -> Bool in
                    a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
                })
                
                self.pages = newPages
                
        }
    }
    
        //Mark: - Gesture Actions
    func setupLongPressRecognizer () {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SavedPagesCollectionViewController.handleLongPress(_:)))
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
    
    //Cell Card View Delegate
    
    func handleCatagoryButton(page: Page) {
        senderPage = page
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
    func handleDeleteButton(page: Page) {
        //handleDelete
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete this page? It will be removed from all of your topics.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ... Canacel - do nothing
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            // ...Completely Delete Record
            InboxManager.sharedInstance.deletePrivatePage(page)
            if let pageIndex = self.pages.indexOf({$0.pageID == page.pageID}) {
                self.collectionView?.performBatchUpdates({
                    self.pages.removeAtIndex(pageIndex)
                    self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: pageIndex, inSection: 0)])

                    }, completion: { (success) in
                        //
                })
            }
        }
        alertController.addAction(OKAction)
        
        self.presentViewController(alertController, animated: true) {
            // completion
        }
    }
    
    func handleShareButton(page: Page) {
        //handleShare
        var sharingItems = [AnyObject]()
        
        if let url = page.URLString {
            sharingItems.append(url)
        }
        
        if let text = page.name {
            sharingItems.append(text)
        }
        if let image = page.image {
            sharingItems.append(image)
        }

        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
}


