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
import Graph

private let reuseIdentifier = "SavedPagesCell"

class SavedPagesCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate, SFSafariViewControllerDelegate, PageLabelViewDelegate {

    var pages = [Page]() {
        didSet{
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.collectionView?.reloadData()
            }
        }
    }
    var tabView: PullTabView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupLongPressRecognizer()
        setupTabView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getPages), name: "ReloadData", object: nil)
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        //
    }
    
    func setupTabView() {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        let ds = PagesPullTabDataSource(collectionView: cv)
        tabView = PullTabView(dataSource: ds, referenceView: view, collectionView: cv)
        view.addSubview(tabView!)
        tabView!.layoutSubviews()
    }
    
    func setupCollectionView() {
        collectionView?.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
    }
    
    override func viewWillAppear(animated: Bool) {
        getPages()
    }
    
    func getPages() {
        DataSource.sharedInstance.getPrivatePages { (fetchedPages) in
            self.pages = SearchAndSortAssistant().sortPages(SortType.DateNewToOld, pages: fetchedPages)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
      override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowDetail" {
            let senderID = sender as! SavedPageCollectionViewCell
            let detailView = segue.destinationViewController as!DetailViewContoller
            detailView.URLString = senderID.page.URLString
        }
    }

    // MARK: UICollectionViewDataSource


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> SavedPageCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)as! SavedPageCollectionViewCell
    
        // Configure the cell
            cell.labelView.delegate = self
            cell.page = pages[indexPath.row]
            cell.layoutSubviews()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height = CGFloat(190.0)
        return CGSizeMake(width, height)
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let URLString = pages[indexPath.row].URLString
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
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
            let senderPage = self.pages [path.row]
            launchTopicOptionAlertView(senderPage)
        }
    }
    
    func launchTopicOptionAlertView(senderPage: Page) {
        let alertController = UIAlertController(title: nil, message: "Where would you like to send this page?", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ... canceled do nothing
        }
        alertController.addAction(cancelAction)
        
        let privateOption = UIAlertAction(title: "Private Topic", style: .Default) { (action) in
            AssignTopicPopupVC.presentPopupCV(self, page: senderPage, shared: false)
        }
        alertController.addAction(privateOption)
        
        let sharedOption = UIAlertAction(title: "Shared Topic", style: .Default) { (action) in
            AssignTopicPopupVC.presentPopupCV(self, page: senderPage, shared: true)
        }
        alertController.addAction(sharedOption)
        
        self.presentViewController(alertController, animated: true) {
            // completion handler
        }
    }
}

extension SavedPagesCollectionViewController {
    
    //Cell Card View Delegate
    
    func openButtonPressed(page: Page) {
        let URLString = page.URLString
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    
    func catagoryButtonPressed(page: Page) {
        launchTopicOptionAlertView(page)
    }
    func deleteButtonPressed(page: Page) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete this page? It will be removed from all of your topics.", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ... Canacel - do nothing
        }
        alertController.addAction(cancelAction)
        let OKAction = UIAlertAction(title: "Delete", style: .Destructive) { (action) in
            // ...Completely Delete Record
            DataCoordinatorInterface.sharedInstance.deletePage(page)
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
    
    func shareButtonPressed(page: Page) {
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


