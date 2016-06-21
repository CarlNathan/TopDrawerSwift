//
//  SharedTableViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

class SharedTableViewController: UITableViewController {

    var sharedTopics = [Topic]() {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharedTableViewController.newTopic(_:)), name: "NewPublicTopic", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharedTableViewController.newRemoteTopic(_:)), name: "RemoteTopic", object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getTopics()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func newTopic(sender: NSNotification) {
        self.sharedTopics.append(sender.userInfo!["topic"]as!Topic)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    func newRemoteTopic(sender: NSNotification) {
        let recordID = sender.userInfo!["topicID"] as! CKRecordID
        InboxManager.sharedInstance.getPublicTopicWithID(recordID) { (topic) -> Void in
            self.sharedTopics.append(topic!)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }

    // MARK: - Table view data source


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedTopics.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> SharedTopicTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! SharedTopicTableViewCell

        // Configure the cell...
        cell.topic = self.sharedTopics[indexPath.row]
        cell.textLabel!.text = sharedTopics[indexPath.row].name
        var usersString = ""
        for user in cell.topic.users! {
            let friend = DataSource.sharedInstance.friendForID(user)
            usersString +=  (friend?.firstName)! + " " + (friend?.familyName)! + "   "
        }
        cell.detailTextLabel!.text = usersString
        cell.accessoryType = .DetailButton

        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessages" {
            let senderID = sender as! SharedTopicTableViewCell
            let topicPageView = segue.destinationViewController as!MessageContainerViewController
            topicPageView.topic = senderID.topic
        } else if segue.identifier == "newTopic" {
    // perform new topic task
        }
    }


    func getTopics () {
        DataSource.sharedInstance.getPublicTopics { (fetchedTopics) in
            self.sharedTopics = fetchedTopics
        }
    }
    @IBAction func addButtonPressed(sender: AnyObject) {
        NewTopicPopupVC.presentPopupCV(self)
    }
}
