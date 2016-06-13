//
//  InsertTopicMarkerPopupVC.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/27/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol TopicMarkerSelectionDelegate {
    func didSelectPageForMarker(page:Page)
}

class InsertTopicMarkerPopupVC: UIViewController {
    
    var delegate: TopicMarkerSelectionDelegate?
    var topic: Topic!
    var pages: [Page] = [Page]()
    var collectionView: UICollectionView!
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
    
    class func presentPopupCV(sender: UIViewController, topic: Topic, delegate: TopicMarkerSelectionDelegate) {
        sender.navigationController?.definesPresentationContext = true
        let popup = InsertTopicMarkerPopupVC()
        popup.delegate = delegate
        popup.topic = topic
        popup.view.backgroundColor = MaterialColor.clear
        sender.navigationController?.tabBarController!.presentViewController(popup, animated: true) {
            //completion
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
    
    override func viewDidLoad() {
        prepareCollectionView()
        prepareCardView()
        setupCardViewSnapBehavior()
        getPages()

    }
    
    func prepareCollectionView() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(SharedPageCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = MaterialColor.grey.lighten2
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
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
        titleLabel.text = "Inset Topic Marker"
        titleLabel.textAlignment = .Center
        titleLabel.textColor = MaterialColor.blueGrey.darken4
        
        let closeButton: FlatButton = FlatButton()
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.addTarget(self, action: #selector(cancelWasPressed), forControlEvents: .TouchUpInside)
        
        cardView.titleLabel = titleLabel
        cardView.detailView = collectionView
        cardView.leftButtons = [closeButton]
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        MaterialLayout.alignToParent(view, child: cardView, left: 15, right: 15, top: 50, bottom: 50)
    }
    
    func getPages () {
        InboxManager.sharedInstance.getPublicTopicPages(self.topic!) { (pages) -> Void in
            self.pages = pages!
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
            
        }
    }
    
    func cancelWasPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension InsertTopicMarkerPopupVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count

        }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! SharedPageCollectionViewCell
        
        // Configure the cell
        cell.page = pages[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = collectionView.bounds.width - 20
        let height = CGFloat(150.0)
        return CGSizeMake(width, height)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.didSelectPageForMarker(pages[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

extension InsertTopicMarkerPopupVC {
    
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
