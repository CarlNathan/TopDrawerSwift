//
//  SavedPagesCollectionViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "Cell"

class SavedPagesCollectionViewController: UICollectionViewController {

    var pages = [Page]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadSavedPages()
        
        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
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
        return pages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
    
        // Configure the cell
    
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
            
            let privateDB = CKContainer.defaultContainer().privateCloudDatabase
            let predicate = NSPredicate(value: true)
            let querry = CKQuery(recordType: "Page", predicate: predicate)
            privateDB.performQuery(querry, inZoneWithID: nil) { (Pages, error) -> Void in
                if let e = error {
                    print("failed to load: \(e.localizedDescription)")
                    return
                }
                for page in Pages! {
                    
                    let imageAsset = page["image"] as! CKAsset
                    let image = UIImage(contentsOfFile: imageAsset.fileURL.path!)
                    
                    let name = page["name"] as! String
                    let description = page["description"] as! String
                    let date = page["date"] as! NSDate
                    let URLString = page["URLString"] as! String
                    let newPage = Page(name: name, description: description, URLString: URLString, image: image!, date:  date)
                    self.pages.append(newPage)
                    
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView!.reloadData()
                    
                })
            }
        }

    }

