//
//  NewTopicEntryTableViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class NewTopicEntryTableViewController: UITableViewController {
    
    let entryParameters = ["Name", "Recipients", "Message"]
    var selectedFriends = [String]()
    var message = ""
    var name = ""
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
        tableView.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateName), name: "NameWasSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateMessage), name: "MessageWasSet", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateSelectedFriends), name: "UpadatedSelectedFriends", object: nil)

    }
    
    func updateName(sender: NSNotification) {
        let dictionary = sender.userInfo as! [String: String]
        name = dictionary["text"]!
        tableView.reloadData()
    }
    func updateMessage(sender: NSNotification) {
        let dictionary = sender.userInfo as! [String: String]
        message = dictionary["text"]!
        tableView.reloadData()
    }
    
    func updateSelectedFriends(sender: NSNotification){
        let dictionary = sender.userInfo as! [NSString: [String]]
        selectedFriends = dictionary["friends"]!
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.hidden = true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return entryParameters.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return entryParameters[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        switch entryParameters[indexPath.section] {
        case "Name":
            if name == "" {
                cell.textLabel!.text = "None"
            } else {
            cell.textLabel!.text = name
            }
            return cell
        case "Recipients":
            if selectedFriends.count > 0 {
                var text: String = ""
                for CKID in selectedFriends {
                    let person = InboxManager.sharedInstance.friends[CKID]!as Friend
                    let name = person.firstName! + " " + person.familyName! + "   "
                    text += name
                }
                cell.textLabel!.text = text
            } else {
                cell.textLabel!.text = "Select"
            }
            return cell
        case "Message":
            if message == "" {
                cell.textLabel!.text = "None"
            } else {
            cell.textLabel!.text = message
            }
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch entryParameters[indexPath.section] {
        case "Name":
            let text = TextEntryViewController(placeholder: entryParameters[indexPath.section])
            if name != "" {
                text.content = name
            }
            navigationController?.pushViewController(text, animated: true)
            break
        case "Recipients":
            let friendsController = FriendsTableView()
            friendsController.selectedFriends = selectedFriends
            navigationController?.pushViewController(friendsController, animated: true)
            break
        case "Message":
            let text = TextEntryViewController(placeholder: entryParameters[indexPath.section])
            if name != "" {
                text.content = message
            }
            navigationController?.pushViewController(text, animated: true)
            break
        default:
            break
        }
        
    }
}