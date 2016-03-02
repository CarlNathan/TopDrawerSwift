//
//  TopicMarkerSelectionTableViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/1/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit

protocol TopicMarkerSelectionDelegate {
    func didSelectPageForMarker(page:Page)
}


class TopicMarkerSelectionTableViewController: UITableViewController {

    var delegate: TopicMarkerSelectionDelegate?
    var topic: Topic?
    var pages = [Page]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.tableView?.userInteractionEnabled = false
        getPages()
        
    }
    

    // MARK: - Table view data source


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        // Configure the cell...
        let page = pages[indexPath.row]
        cell.textLabel!.text = page.name
        cell.imageView!.image = page.image
        cell.imageView!.contentMode = .ScaleAspectFill
        cell.imageView!.clipsToBounds = true
        cell.imageView!.layer.cornerRadius = 10

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.tableView.contentOffset.y < -100 {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
