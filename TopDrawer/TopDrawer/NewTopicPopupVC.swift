//
//  TopicTableCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material
import UIKit
import CloudKit

class NewTopicPopupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //
    var friends: [Friend]?
    var selectedFriends = [String]()
    var isShared: Bool?
    var page: Page?
    let tableView = UITableView()
    var cardView: CardView!
    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.view)
    }()
    var attachment: UIAttachmentBehavior!

    
    init() {
        super.init(nibName:nil, bundle:nil)
        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalTransitionStyle = .CrossDissolve
        modalPresentationStyle = .OverCurrentContext
        
    }
    
    class func presentPopupCV(sender: UIViewController) {
        sender.navigationController?.definesPresentationContext = true
        let popup = NewTopicPopupVC()
        popup.view.backgroundColor = MaterialColor.clear
        sender.navigationController?.tabBarController!.presentViewController(popup, animated: true) {
            //completion
        }
    }
    
    override func viewDidLoad() {
        self.friends = Array(InboxManager.sharedInstance.friends.values)
        prepareTableView()
        prepareCardView()
        setupCardViewSnapBehavior()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.5, animations: {
            self.view.backgroundColor = MaterialColor.black.colorWithAlphaComponent(0.5)
            
        })
    }
    
    func prepareTableView() {
        tableView.registerClass(FriendTableViewCell.self, forCellReuseIdentifier: "friendCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = MaterialColor.grey.lighten5
    }
    
    func prepareCardView() {
        cardView = CardView()
        cardView.pulseColor = nil
        cardView.backgroundColor = MaterialColor.grey.lighten4
        cardView.cornerRadiusPreset = .Radius1
        cardView.divider = false
        cardView.contentInsetPreset = .None
        cardView.leftButtonsInsetPreset = .Square2
        cardView.rightButtonsInsetPreset = .Square2
        cardView.detailViewInsetPreset = .None
        
        let titleLabel: UILabel = UILabel()
        titleLabel.font = RobotoFont.lightWithSize(20)
        titleLabel.text = "Topics"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.blueGrey.darken4
        
        let closeButton: FlatButton = FlatButton()
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: #selector(cancelWasPressed), forControlEvents: .TouchUpInside)
        
        let settingButton: FlatButton = FlatButton()
        settingButton.setTitle("Assign", forState: .Normal)
        settingButton.tintColor = MaterialColor.blue.accent3
        settingButton.addTarget(self, action: #selector(saveButtonPressed), forControlEvents: .TouchUpInside)
        
        // Use MaterialLayout to easily align the tableView.
        cardView.titleLabel = titleLabel
        cardView.detailView = tableView
        cardView.leftButtons = [closeButton]
        cardView.rightButtons = [settingButton]
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        MaterialLayout.alignToParent(view, child: cardView, left: 15, right: 15, top: 100, bottom: 100)
    }
    
    //TableView
    
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
    
    func saveButtonPressed(sender: AnyObject) {
        
        if selectedFriends.count == 0 {
            //InboxManager.sharedInstance.createNewTopic(self.nameTextField.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //InboxManager.sharedInstance.createNewPublicTopic(self.nameTextField.text!, users: selectedFriends)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func cancelWasPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //nameTextField.resignFirstResponder()
    }
    
    func setupCardViewSnapBehavior(){
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        cardView.addGestureRecognizer(swipe)
    }
    
    
    func didPan(gesture: UIPanGestureRecognizer) {
        let detailLocation = gesture.locationInView(gesture.view!)
        let location = gesture.locationInView(gesture.view!.superview)
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
            let offset = UIOffsetMake(detailLocation.x - CGRectGetMidX(cardView.bounds), detailLocation.y - CGRectGetMidY(cardView.bounds))
            attachment = UIAttachmentBehavior(item: gesture.view!, offsetFromCenter: offset, attachedToAnchor: location)
            attachment.length = 10
            attachment.frictionTorque = 0.05
            animator.addBehavior(attachment)
            
        case .Changed:
            attachment.anchorPoint = location;
            
        case .Ended:
            animator.removeAllBehaviors()
            let snap = UISnapBehavior(item: gesture.view!, snapToPoint: view.center)
            animator.addBehavior(snap)
        default:
            return
        }
        
    }


}


class FriendTableViewCell: UITableViewCell {
    var friend: Friend!
    override func prepareForReuse() {
        self.accessoryType = .None
    }
}

