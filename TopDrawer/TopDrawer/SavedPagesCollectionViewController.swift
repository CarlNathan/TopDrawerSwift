//
//  SavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "SavedPagesCell"

class SavedPagesCollectionViewController: UICollectionViewController {

    var pages = [Page]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSavedPages()
        
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
    
        //MARK: Helper
    
    func downloadSavedPages () {
            
            let privateDB = CKContainer.defaultContainer().publicCloudDatabase
            let predicate = NSPredicate(value: true)
            let querry = CKQuery(recordType: "Page", predicate: predicate)
            privateDB.performQuery(querry, inZoneWithID: nil) { (Pages, error) -> Void in
                if let e = error {
                    print("failed to load: \(e.localizedDescription)")
                    return
                }
                for page in Pages! {
                    
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

