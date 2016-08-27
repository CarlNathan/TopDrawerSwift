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

class SavedPagesCollectionViewController: UICollectionViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate, SFSafariViewControllerDelegate {

    var pages = [Page]() {
        didSet{
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.collectionView?.reloadData()
                if self.pages.count == 0 {
                    self.emptyView.hidden = false
                    self.collectionView!.hidden = true
                } else {
                    self.emptyView.hidden = true
                    self.collectionView!.hidden = false
                }
            }
        }
    }
    var previousTopicPages: [Page] = [Page]()
    var topic: String = "Recently Added"
    var searchEnabled: Bool = false
    var searchTerm: String = ""
    var tabView: PullTabView?
    let emptyView = EmptyPageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        //setupLongPressRecognizer()
        setupEmptyView()
        setupTabView()
        findCustomNav()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadData), name: "ReloadData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(launchNewTopic), name: "NewTopicPressed", object: nil)
        
        // Do any additional setup after loading the view.
        
    }
    
    func launchNewTopic() {
        NewPrivateTopicPopupVC.presentPopupCV(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        DataSource.sharedInstance.getPrivatePages { (_) in
            self.reloadData()
        }
    }
    
    func reloadData() {
        if topic == "Recently Added" {
            DataSource.sharedInstance.getPrivatePages({ (fetchedPages) in
                let sort = SearchAndSortAssistant()
                if self.searchEnabled {
                    self.previousTopicPages = sort.sortPages(SortType.DateNewToOld, pages: sort.filterRecentPages(fetchedPages))
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.searchPage(self.searchTerm, pages: self.previousTopicPages))
                } else {
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.filterRecentPages(fetchedPages))
                }
            })
        } else if topic == "All Pages" {
            DataSource.sharedInstance.getPrivatePages({ (fetchedPages) in
                if self.searchEnabled {
                    let sort = SearchAndSortAssistant()
                    self.previousTopicPages = sort.sortPages(SortType.DateNewToOld, pages: fetchedPages)
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.searchPage(self.searchTerm, pages: self.previousTopicPages))
                } else {
                    self.pages = SearchAndSortAssistant().sortPages(SortType.DateNewToOld, pages: fetchedPages)
                }
            })
        } else if topic == "Uncatagorized" {
            DataSource.sharedInstance.getPrivatePages({ (fetchedPages) in
                let sort = SearchAndSortAssistant()
                if self.searchEnabled {
                    self.previousTopicPages = sort.sortPages(SortType.DateNewToOld, pages: sort.filterUncatagorizedPages(fetchedPages))
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.searchPage(self.searchTerm, pages: self.previousTopicPages))
                } else {
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.filterUncatagorizedPages(fetchedPages))
                }
            })
        } else {
            DataSource.sharedInstance.getPagesForTopic(topic, completion: { (fetchedPages) in
                if self.searchEnabled {
                    let sort = SearchAndSortAssistant()
                    self.previousTopicPages = sort.sortPages(SortType.DateNewToOld, pages: fetchedPages)
                    self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.searchPage(self.searchTerm, pages: self.previousTopicPages))
                } else {
                    self.pages = SearchAndSortAssistant().sortPages(SortType.DateNewToOld, pages: fetchedPages)
                }
            })
        }
    }
    
    func setupTabView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        let ds = PagesPullTabDataSource(collectionView: cv)
        tabView = PullTabView(dataSource: ds, referenceView: view, collectionView: cv)
        view.addSubview(tabView!)
        tabView!.layoutSubviews()
        tabView?.collectionView.delegate = self
    }
    
    func setupCollectionView() {
        collectionView?.backgroundColor = MaterialColor.grey.lighten1
        collectionView?.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        collectionView?.alwaysBounceVertical = true
        
    }
    
    func setupEmptyView() {
        emptyView.frame = view.bounds
        emptyView.backgroundColor = MaterialColor.grey.lighten1
        view.addSubview(emptyView)
    }
    
    func findCustomNav() {
        let nav = navigationController as? CustomNavController
        if let n = nav {
            n.searchDelegate = self
        }
    }
    
    func getPages() {
        DataSource.sharedInstance.getPrivatePages { (fetchedPages) in
            self.pages = SearchAndSortAssistant().sortPages(SortType.DateNewToOld, pages: fetchedPages)
        }
    }
    
    func presentPages(pages: [Page]) {
        self.pages = pages
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

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)as! PageCollectionViewCell
    
        // Configure the cell
            cell.configureCell(pages[indexPath.row])
            cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if collectionView == self.collectionView {
            let width = collectionView.bounds.width
            let height = CGFloat(120.0)
            return CGSizeMake(width, height)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 40)
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if collectionView == self.collectionView {
            let URLString = pages[indexPath.row].URLString
            let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
            sfc.delegate = self
            presentViewController(sfc, animated: true, completion: nil)
        } else {
            if indexPath.row == 0 {
                topic = "All Pages"
                reloadData()
            } else if indexPath.row == 1 {
                topic = "Recently Added"
                reloadData()
            } else if indexPath.row == 2 {
                topic = "Uncatagorized"
                reloadData()
            } else {
                let data = collectionView.dataSource as! PagesPullTabDataSource
                let topic = data.topics[indexPath.row - 3]
                self.topic = topic.recordID!
                reloadData()
            }
        }
    }
    
    func didSelectTopic(title: String) {
        tabView?.menuCloseAfterSelection()
        tabView?.setTitle(title)
    }
    
//    
//        //Mark: - Gesture Actions
//    func setupLongPressRecognizer () {
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(SavedPagesCollectionViewController.handleLongPress(_:)))
//        longPress.delegate = self
//        longPress.delaysTouchesBegan = true
//        self.collectionView?.addGestureRecognizer(longPress)
//    }
//    
//    func handleLongPress (sender: UIGestureRecognizer) {
//        let p = sender.locationInView(self.collectionView)
//        if let path = self.collectionView?.indexPathForItemAtPoint(p) {
//            let senderPage = self.pages [path.row]
//            launchTopicOptionAlertView(senderPage)
//        }
//    }
//    
//    func launchTopicOptionAlertView(senderPage: Page) {
//        let alertController = UIAlertController(title: nil, message: "Where would you like to send this page?", preferredStyle: .ActionSheet)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
//            // ... canceled do nothing
//        }
//        alertController.addAction(cancelAction)
//        
//        let privateOption = UIAlertAction(title: "Private Topic", style: .Default) { (action) in
//            AssignTopicPopupVC.presentPopupCV(self, page: senderPage, shared: false)
//        }
//        alertController.addAction(privateOption)
//        
//        let sharedOption = UIAlertAction(title: "Shared Topic", style: .Default) { (action) in
//            AssignTopicPopupVC.presentPopupCV(self, page: senderPage, shared: true)
//        }
//        alertController.addAction(sharedOption)
//        
//        self.presentViewController(alertController, animated: true) {
//            // completion handler
//        }
//    }
}


extension SavedPagesCollectionViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let nav = navigationController as! CustomNavController
        nav.searchView.searchEntryField.resignFirstResponder()
    }
}

extension SavedPagesCollectionViewController: PageCollectionViewCellDelegate {
    
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
    
    func topicButtonPressed(page: Page) {
        AssignTopicPopupVC.presentPopupCV(self, page: page, shared: false)
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

extension SavedPagesCollectionViewController: CustomNavControllerSearchDelegate {
    func searchInputDidChange(text: String) {
        searchTerm = text
        if text == "" {
            pages = previousTopicPages
        } else {
            let sort = SearchAndSortAssistant()
            self.pages = sort.sortPages(SortType.DateNewToOld, pages: sort.searchPage(text, pages: previousTopicPages))
        }
    }
    func searchDidBecomeActive() {
        previousTopicPages = pages
        searchEnabled = true
    }
    func searchDidBecomeInactive() {
        pages = previousTopicPages
        searchEnabled = false
        searchTerm = ""
    }
}
