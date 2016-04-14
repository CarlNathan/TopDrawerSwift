//
//  AssignTopicTableCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material
import UIKit
import CloudKit

class AssignTopicPopupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //
    var topics =  [Topic]()
    var selectedTopics = [CKRecordID]()
    var isShared: Bool?
    var page: Page?
    let tableView = UITableView()
    
    init() {
        super.init(nibName:nil, bundle:nil)
        modalTransitionStyle = .CoverVertical
        modalPresentationStyle = .OverCurrentContext
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalTransitionStyle = .CoverVertical
        modalPresentationStyle = .Popover
        
    }
    
    
    class func presentPopupCV(sender: UIViewController, page: Page, shared: Bool) {
        sender.navigationController?.definesPresentationContext = true
        let popup = AssignTopicPopupVC()
        popup.page = page
        popup.isShared = shared
        popup.view.backgroundColor = UIColor.clearColor()
        sender.presentViewController(popup, animated: true) {
            //completion
        }
    }
    
    override func viewDidLoad() {
        prepareTableView()
        prepareCardView()
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
    
    func prepareTableView() {
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "topicCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func prepareCardView() {
        let cardView: CardView = CardView()
        cardView.pulseColor = nil
        cardView.backgroundColor = MaterialColor.grey.lighten5
        cardView.cornerRadiusPreset = .Radius1
        cardView.divider = false
        cardView.contentInsetPreset = .None
        cardView.leftButtonsInsetPreset = .Square2
        cardView.rightButtonsInsetPreset = .Square2
        cardView.detailViewInsetPreset = .None
        
        let titleLabel: UILabel = UILabel()
        titleLabel.font = RobotoFont.mediumWithSize(20)
        titleLabel.text = "Messages"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.blueGrey.darken4
        
        let v: UIView = UIView()
        v.backgroundColor = MaterialColor.blue.accent1
        
        let closeButton: FlatButton = FlatButton()
        closeButton.setTitle("Close", forState: .Normal)
        
        let image: UIImage? = UIImage(named: "ic_settings")?.imageWithRenderingMode(.AlwaysTemplate)
        let settingButton: FlatButton = FlatButton()
        settingButton.tintColor = MaterialColor.blue.accent3
        settingButton.setImage(image, forState: .Normal)
        settingButton.setImage(image, forState: .Highlighted)
        
        // Use MaterialLayout to easily align the tableView.
        cardView.titleLabel = titleLabel
        cardView.detailView = tableView
        cardView.leftButtons = [closeButton]
        cardView.rightButtons = [settingButton]
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        MaterialLayout.alignToParent(view, child: cardView, left: 10, right: 10, top: 100, bottom: 100)
    }
    
    //TableView
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! TopicTableViewCell
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
            InboxManager.sharedInstance.savePageToPublicTopics(self.page!, topics: selectedTopics)
        } else {
            InboxManager.sharedInstance.savePageToTopics(self.page!, topics: selectedTopics)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

class TopicTableViewCell: UITableViewCell {
    var topic: Topic!
    override func prepareForReuse() {
        self.accessoryType = UITableViewCellAccessoryType.None
    }
}