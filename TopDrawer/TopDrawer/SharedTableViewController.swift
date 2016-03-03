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

    var sharedTopics = [Topic]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //sharedTopics = InboxManager.sharedInstance.checkMessages()
        
        getTopics()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTopic:", name: "NewPublicTopic", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newRemoteTopic:", name: "RemoteTopic", object: nil)

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
        // #warning Incomplete implementation, return the number of rows
        return sharedTopics.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> SharedTopicTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! SharedTopicTableViewCell

        // Configure the cell...
        cell.topic = self.sharedTopics[indexPath.row]
        cell.textLabel!.text = sharedTopics[indexPath.row].name
        var usersString = ""
        for user in cell.topic.users! {
            usersString += user.firstName! + " " + user.familyName! + "   "
        }
        cell.detailTextLabel!.text = usersString

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


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
        InboxManager.sharedInstance.getPublicTopics { (topics) -> Void in
            self.sharedTopics = topics!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
}
