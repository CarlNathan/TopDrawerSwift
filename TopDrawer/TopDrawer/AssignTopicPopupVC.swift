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

class AssignTopicPopupVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    var topics =  [Topic]() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let ST = self.page?.topic {
                    self.selectedTopics = ST
                }
                self.tableView.reloadData()
            })
        }
    }
    var selectedTopics = [String]()
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
    
    class func presentPopupCV(sender: UIViewController, page: Page, shared: Bool) {
        sender.navigationController?.definesPresentationContext = true
        let popup = AssignTopicPopupVC()
        popup.page = page
        popup.isShared = shared
        popup.view.backgroundColor = MaterialColor.clear
        sender.navigationController?.presentViewController(popup, animated: true) {
            //completion
        }
    }
    
    override func viewDidLoad() {
        prepareTableView()
        prepareCardView()
        setupCardViewSnapBehavior()
        getTopics()
    }
    
    private func getTopics() {
        if isShared! {
            DataSource.sharedInstance.getPublicTopics({ (fetchedTopics) in
                self.topics = SearchAndSortAssistant().sortTopics(fetchedTopics)
            })
        } else {
            DataSource.sharedInstance.getPrivateTopics({ (fetchedTopics) in
                self.topics = SearchAndSortAssistant().sortTopics(fetchedTopics)
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animateWithDuration(0.5, animations: {
            self.view.backgroundColor = MaterialColor.black.colorWithAlphaComponent(0.5)
            
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animateWithDuration(0.4) {
            self.cardView.frame = CGRectMake(-100, -100, 500, 800)
        }
    }
    
    func prepareTableView() {
        tableView.registerClass(TopicTableViewCell.self, forCellReuseIdentifier: "topicCell")
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
        settingButton.addTarget(self, action: #selector(saveTopics), forControlEvents: .TouchUpInside)
        
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
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath) as! TopicTableViewCell
        cell.backgroundColor = MaterialColor.grey.lighten5
        cell.topic = self.topics[indexPath.row]
        cell.textLabel!.text = topics[indexPath.row].name
        cell.textLabel!.font = RobotoFont.lightWithSize(14)
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
    
    func cancelWasPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveTopics(sender: AnyObject) {
        if isShared! {
            SavingInterface.sharedInstance.assignPageToPublicTopics(page!, topics: selectedTopics)
        } else {
            SavingInterface.sharedInstance.assignPageToPrivateTopics(page!, topics: selectedTopics)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension AssignTopicPopupVC {
    
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

class TopicTableViewCell: UITableViewCell {
    var topic: Topic!
    override func prepareForReuse() {
        self.accessoryType = UITableViewCellAccessoryType.None
    }
}