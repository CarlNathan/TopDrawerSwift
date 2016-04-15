//
//  NewTopicViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/29/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import CloudKit

class NewTopicViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var friends: [Friend]?
    var selectedFriends = [String]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.friends = Array(InboxManager.sharedInstance.friends.values)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Mark: - TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        
        cell.friend = self.friends![indexPath.row]
        cell.textLabel!.text = friends![indexPath.row].firstName! + " " + friends![indexPath.row].familyName!
        if selectedFriends.contains(cell.friend.recordID!) {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = friends![indexPath.row]
        if let index = selectedFriends.indexOf(friend.recordID!){
            selectedFriends.removeAtIndex(index)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .None
        } else {
            selectedFriends.append(friends![indexPath.row].recordID!)
            let cell = self.tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
    }

    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        if selectedFriends.count == 0 {
            InboxManager.sharedInstance.createNewTopic(self.nameTextField.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            InboxManager.sharedInstance.createNewPublicTopic(self.nameTextField.text!, users: selectedFriends)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func cancelWasPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameTextField.resignFirstResponder()
    }
}

