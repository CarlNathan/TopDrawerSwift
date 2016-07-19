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

class NewTopicPopupVC: UIViewController {
    //
    var selectedFriends = [String]()
    var subjectName: String?
    var messageText: String?
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
        sender.navigationController?.presentViewController(popup, animated: true) {
            //completion
        }
    }
    
    override func viewDidLoad() {
        prepareCardView()
        setupCardViewSnapBehavior()

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
            self.cardView.frame = CGRectMake(-100, -100, self.view.bounds.width+100, self.view.bounds.height+100)
        }
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
        titleLabel.text = "New Topic"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.blueGrey.darken4
        
        let closeButton: FlatButton = FlatButton()
        closeButton.setTitle("Cancel", forState: .Normal)
        closeButton.addTarget(self, action: #selector(cancelWasPressed), forControlEvents: .TouchUpInside)
        
        let settingButton: FlatButton = FlatButton()
        settingButton.setTitle("Create", forState: .Normal)
        settingButton.tintColor = MaterialColor.blue.accent3
        settingButton.addTarget(self, action: #selector(saveButtonPressed), forControlEvents: .TouchUpInside)
        
        // Use MaterialLayout to easily align the tableView.
        cardView.titleLabel = titleLabel
        let entryController = NewTopicEntryTableViewController()
        entryController.delegate = self
        let nav = UINavigationController(rootViewController: entryController)
        addChildViewController(nav)
        nav.didMoveToParentViewController(self)
        cardView.detailView = nav.view
        cardView.leftButtons = [closeButton]
        cardView.rightButtons = [settingButton]
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        MaterialLayout.alignToParent(view, child: cardView, left: 15, right: 15, top: 100, bottom: 100)
    }
    
        
    func saveButtonPressed(sender: AnyObject) {
        if subjectName != nil {
            if selectedFriends.count == 0 {
                let topic = Topic(name: subjectName, users: nil, recordID: nil)
                SavingInterface.sharedInstance.createNewPrivateTopic(topic)
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                let topic = Topic(name: subjectName, users: selectedFriends, recordID: nil)
                SavingInterface.sharedInstance.createNewSharedTopic(topic, completion: { (savedTopic) in
                    if self.messageText != nil {
                        let message = Message(sender: DataCoordinatorInterface.sharedInstance.user!.ID, body: self.messageText, topic: savedTopic.recordID, date: NSDate())
                        SavingInterface.sharedInstance.saveMessage(message)
                    }
                })
            }
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

extension NewTopicPopupVC: NewTopicEntryTableViewControllerDelegate {
    func updateEntryFields(name: String, selectedFriends: [String], message: String) {
        self.subjectName = name
        self.selectedFriends = selectedFriends
        self.messageText = message
    }

}

