//
//  AssignTopicViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/28/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

class AssignTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var topics =  [Topic]()
    var selectedTopics = [CKRecordID]()
    var isShared: Bool?
    var page: Page?
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleLabel.text = self.page?.name
        if self.isShared! {
            InboxManager.sharedInstance.getPublicTopics({ (topics) -> Void in
                self.topics = topics!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })
        } else {
            InboxManager.sharedInstance.getTopics({ (topics) -> Void in
                self.topics = topics!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
        // Mark: - TableView
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! TopicsTableViewCell
        cell.topic = self.topics[indexPath.row]
        cell.textLabel!.text = topics[indexPath.row].name
        if selectedTopics.contains(cell.topic.recordID!){
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let topic = topics[indexPath.row]
        if let index = selectedTopics.indexOf(topic.recordID!){
            selectedTopics.removeAtIndex(index)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .None
        } else {
            selectedTopics.append(topics[indexPath.row].recordID!)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
    }
    @IBAction func saveTopics(sender: AnyObject) {
        
        InboxManager.sharedInstance.savePageToTopics(self.page!, topics: selectedTopics)
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}

class TopicsTableViewCell: UITableViewCell {
    var topic: Topic!
    override func prepareForReuse() {
        self.accessoryType = UITableViewCellAccessoryType.None
    }
}
