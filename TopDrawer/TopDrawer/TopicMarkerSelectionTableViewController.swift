//
//  TopicMarkerSelectionTableViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/1/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit


class TopicMarkerSelectionTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!

    var delegate: TopicMarkerSelectionDelegate?
    var topic: Topic?
    var pages = [Page]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        self.tableView?.userInteractionEnabled = false
        getPages()
        setupTableFrame()
        
    }
    

    // MARK: - Table view data source


     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("selectionId", forIndexPath: indexPath) as! TopicMarkerSelectionTableViewCell

        // Configure the cell...
        let page = pages[indexPath.row]
        cell.titleLabel!.text = page.name
        cell.topicImageView!.image = page.image
        cell.topicImageView!.contentMode = .ScaleAspectFit
        cell.topicImageView!.clipsToBounds = true
        cell.topicImageView!.layer.cornerRadius = 10

        return cell
    }

     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectPageForMarker(pages[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func getPages () {
        InboxManager.sharedInstance.getPublicTopicPages(self.topic!) { (pages) -> Void in
            self.pages = pages!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView?.reloadData()
                self.tableView?.userInteractionEnabled = true
            })
            
        }
    }
    
     func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView.contentOffset.y < -100 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func setupTableFrame () {
                self.automaticallyAdjustsScrollViewInsets = true
        let currentInsets = self.tableView.contentInset
        self.tableView.contentInset = UIEdgeInsets(top: self.topLayoutGuide.length,left: currentInsets.bottom,bottom: currentInsets.left, right: currentInsets.right)
    }

}
