//
//  NewPrivateTopicPopUpVC.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/20/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material
import UIKit

class NewPrivateTopicPopupVC: UIViewController {
    //
    var nameField = TextField()
    var cardView: CardView!
    let saveButton: FlatButton = FlatButton()
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
        let popup = NewPrivateTopicPopupVC()
        popup.view.backgroundColor = MaterialColor.clear
        sender.navigationController?.presentViewController(popup, animated: true) {
            //completion
        }
    }
    
    override func viewDidLoad() {
        prepareNameField()
        prepareCardView()
        setupCardViewSnapBehavior()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cardView.frame = CGRect (x: 0, y: 400, width: 0, height: 0)
        UIView.animateWithDuration(0.3, animations: {
            self.view.backgroundColor = MaterialColor.black.colorWithAlphaComponent(0.5)
            self.view.layoutSubviews()
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animateWithDuration(0.2) {
            self.cardView.frame = CGRectMake(0, 400, 0, 0)
        }
    }
    
    func prepareNameField() {
        nameField.placeholder = "Name"
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
        titleLabel.text = "New Catagory"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.blueGrey.darken4
        
        let closeButton: FlatButton = FlatButton()
        closeButton.setTitle("Cancel", forState: .Normal)
        closeButton.addTarget(self, action: #selector(cancelWasPressed), forControlEvents: .TouchUpInside)
        
        saveButton.setTitle("Create", forState: .Normal)
        saveButton.setTitleColor(MaterialColor.blue.accent3, forState: .Normal)
        saveButton.setTitleColor(MaterialColor.grey.lighten1, forState: .Disabled)
        saveButton.enabled = false
        saveButton.addTarget(self, action: #selector(saveButtonPressed), forControlEvents: .TouchUpInside)
        
        // Use MaterialLayout to easily align the tableView.
        cardView.titleLabel = titleLabel
//        let entryController = TextEntryViewController(placeholder: "Name")
//        addChildViewController(entryController)
//        entryController.didMoveToParentViewController(self)
//        cardView.detailView = entryController.view
        let tev = TextEntryView()
        tev.delegate = self
        cardView.detailView = tev
        cardView.leftButtons = [closeButton]
        cardView.rightButtons = [saveButton]
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        MaterialLayout.alignToParent(view, child: cardView, left: 15, right: 15, top: 60, bottom: 270)
    }
    
    
    func saveButtonPressed(sender: AnyObject) {
        if nameField.text != nil {
            nameField.resignFirstResponder()
            let topic = Topic(name: nameField.text, users: nil, recordID: nil)
            SavingInterface.sharedInstance.createNewPrivateTopic(topic)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelWasPressed(sender: AnyObject) {
        nameField.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameField.resignFirstResponder()
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
            let snap = UISnapBehavior(item: gesture.view!, snapToPoint: CGPoint(x: view.center.x, y: ((view.bounds.height - 330) / 2) + 60))
            animator.addBehavior(snap)
        default:
            return
        }
        
    }
    
    
}

extension NewPrivateTopicPopupVC: TextEntryViewDelegate {
    func textDidChange(text: String) {
        if text == "" {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
}



