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
    var selectedTopics = [String]()
    var isShared: Bool?
    var page: Page? {
        didSet {
            selectedTopics = page!.topic!
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.titleLabel.text = self.page?.name
        self.imageView.image = self.page!.image
        if self.isShared! {
            DataSource.sharedInstance.getPublicTopics({ (topics) in
                self.topics = topics
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            })
        } else {
            DataSource.sharedInstance.getPrivateTopics({ (topics) in
                self.topics = topics
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
    @IBAction func cancelWasPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func saveTopics(sender: AnyObject) {
        if isShared! {
            SavingInterface.sharedInstance.assignPageToPublicTopics(page!, topics: selectedTopics)
        } else {
            SavingInterface.sharedInstance.assignPageToPrivateTopics(page!, topics: selectedTopics)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class TopicsTableViewCell: UITableViewCell {
    var topic: Topic!
    override func prepareForReuse() {
        self.accessoryType = UITableViewCellAccessoryType.None
    }
}
