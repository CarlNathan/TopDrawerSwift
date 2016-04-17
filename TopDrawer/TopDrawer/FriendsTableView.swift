//
//  FriendsTableView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/15/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material
import CloudKit
import UIKit

class FriendsTableView: UITableViewController {
    
    var friends: [Friend]?
    var selectedFriends = [String]()

    override func viewDidLoad() {
        setupTableView()
    }
    
    func setupTableView(){
        self.friends = Array(InboxManager.sharedInstance.friends.values)
        tableView.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = MaterialColor.grey.lighten5
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell
        
        cell.friend = self.friends![indexPath.row]
        cell.textLabel!.text = friends![indexPath.row].firstName! + " " + friends![indexPath.row].familyName!
        if selectedFriends.contains(cell.friend.recordID!) {
            cell.accessoryType = .Checkmark
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let friend = friends![indexPath.row]
        if let index = selectedFriends.indexOf(friend.recordID!){
            selectedFriends.removeAtIndex(index)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .None
        } else {
            selectedFriends.append(friends![indexPath.row].recordID!)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.accessoryType = .Checkmark
        }
    }

}

class FriendTableViewCell: UITableViewCell {
    var friend: Friend!
    override func prepareForReuse() {
        accessoryType = .None
    }
}
