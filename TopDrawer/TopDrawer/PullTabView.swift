//
//  PullTabView.swift
//  PullTabView
//
//  Created by Carl Udren on 7/11/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

/*
 
 View to be attached to a custom naviation controller.  This view will contain a collectionView and rely on the root VC of the navigation controller to provide the data that populates the view.
 */

import Foundation
import UIKit
import Material

protocol PullDownViewDataSource: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func cellClassForCollectionView() -> (String,AnyClass?)
    func imageForTabButton() -> UIImage?
}

private struct LayoutParameters {
    static let tabHeight: CGFloat = 30
}

class PullTabView: UIVisualEffectView {
    
    // Grav related
    
    var grav: UIGravityBehavior!
    
    var referenceView: UIView!
    
    let stripeView = UIView()
    
    
    /// The collection view that makes up the content of the pull down view.
    var collectionView: UICollectionView!
    
    private var tabButton: UIButton!
    
    var animator: UIDynamicAnimator!
    var attachment: UIAttachmentBehavior!

    
    /// The data source delegate that provides the data required to populate collection view content.
    private var tabViewDataSource: PullDownViewDataSource!
    
    
    /**
     Preferred nitializer that deffers initialization to superclass <UIView>
     
     - parameter frame: frame for new view.  This will always be CGRect.zero
     
     - returns: NA
     */
    init(dataSource:PullDownViewDataSource, referenceView: UIView, collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.tabViewDataSource = dataSource
        self.referenceView = referenceView
        animator = UIDynamicAnimator(referenceView: referenceView)
        super.init(effect: UIBlurEffect(style: .Dark))
        setupBackground()
        setupStripeView()
        setupCollectionView()
        setupTabButton()
        setupSnapBehavior()
        grav = UIGravityBehavior(items: [self])
        setupNotifications()

    }
    
    /**
     Required init from coder.
     
     - parameter aDecoder: Coder from Interface Builder.
     
     - returns: NA
     */

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleTabPush), name: "PopDownMenu", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(menuUp), name: "SearchPressed", object: nil)
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return getPath(self).containsPoint(point)
    }
    
    func setupBackground() {
        backgroundColor = UIColor.clearColor()
    }
    
    func setupStripeView() {
        stripeView.backgroundColor = MaterialColor.grey.darken3
        addSubview(stripeView)
    }
    
    func setupCollectionView() {
        collectionView.dataSource = tabViewDataSource
        collectionView.delegate = tabViewDataSource
        let (identifier, aClass): (String, AnyClass?) = tabViewDataSource.cellClassForCollectionView()
        collectionView.registerClass(aClass, forCellWithReuseIdentifier: identifier)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.alwaysBounceVertical = true
        
        addSubview(collectionView)
        
    }
    
    func setupTabButton() {
        tabButton = UIButton()
        tabButton.backgroundColor = UIColor.clearColor()
        tabButton.setTitle("Recently Added", forState: .Normal)
        if let image = tabViewDataSource.imageForTabButton() {
            tabButton.setImage(image, forState: .Normal)
        }
        tabButton.addTarget(self, action: #selector(handleTabPush), forControlEvents: .TouchUpInside)
        addSubview(tabButton)
    }
    
    func menuCloseAfterSelection() {
        animator.removeAllBehaviors()
        grav.gravityDirection = CGVector(dx: 0, dy: -5)
        let collide = UICollisionBehavior(items: [self])
        //collide.translatesReferenceBoundsIntoBoundary = true
        collide.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x:0 , y: -(bounds.height - 69 - LayoutParameters.tabHeight - 1)), toPoint: CGPoint(x:referenceView.bounds.maxX , y: -(bounds.height - 69 - LayoutParameters.tabHeight)))
        collide.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x:0 , y: bounds.height + 69), toPoint: CGPoint(x:referenceView.bounds.maxX , y: bounds.height + 69))
        collide.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x:-1 , y: -1000), toPoint: CGPoint(x: -1 , y: referenceView.bounds.maxX))
        collide.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x:referenceView.bounds.width * (8/10) , y: 0), toPoint: CGPoint(x: referenceView.bounds.width * (8/10) , y: referenceView.bounds.maxX))
        animator.addBehavior(collide)
        animator.addBehavior(grav)
    }
    
    func menuUp() {
        animator.removeAllBehaviors()
        if grav.gravityDirection.dy >= 1 {
            userInteractionEnabled = false
        } else {
            userInteractionEnabled = true
        }
        grav.gravityDirection = CGVector(dx: 0, dy: -5)
        let collide = UICollisionBehavior(items: [self])
        //collide.translatesReferenceBoundsIntoBoundary = true
        collide.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x:0 , y: -(bounds.height - 69 - LayoutParameters.tabHeight - 1)), toPoint: CGPoint(x:referenceView.bounds.maxX , y: -(bounds.height - 69 - LayoutParameters.tabHeight)))
        collide.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x:0 , y: bounds.height + 69), toPoint: CGPoint(x:referenceView.bounds.maxX , y: bounds.height + 69))
        collide.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x:-1 , y: -1000), toPoint: CGPoint(x: -1 , y: referenceView.bounds.maxX))
        collide.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x:referenceView.bounds.width * (8/10) , y: 0), toPoint: CGPoint(x: referenceView.bounds.width * (8/10) , y: referenceView.bounds.maxX))
        animator.addBehavior(collide)
        animator.addBehavior(grav)
    }
    
    func handleTabPush() {
        animator.removeAllBehaviors()
        if grav.gravityDirection.dy <= 1 {
            grav.gravityDirection = CGVector(dx: 0, dy: 5)
        } else {
            grav.gravityDirection = CGVector(dx: 0, dy: -5)
        }
        let collide = UICollisionBehavior(items: [self])
        //collide.translatesReferenceBoundsIntoBoundary = true
        collide.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x:0 , y: -(bounds.height - 69 - LayoutParameters.tabHeight - 1)), toPoint: CGPoint(x:referenceView.bounds.maxX , y: -(bounds.height - 69 - LayoutParameters.tabHeight)))
        collide.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x:0 , y: bounds.height + 69), toPoint: CGPoint(x:referenceView.bounds.maxX , y: bounds.height + 69))
        collide.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x:-1 , y: -1000), toPoint: CGPoint(x: -1 , y: referenceView.bounds.maxX))
        collide.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x:referenceView.bounds.width * (8/10) , y: 0), toPoint: CGPoint(x: referenceView.bounds.width * (8/10) , y: referenceView.bounds.maxX))
        animator.addBehavior(collide)
        animator.addBehavior(grav)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //frame = CGRect(x: 0, y: -50, width: 200, height: 400)
        frame = CGRect(x: 0, y: -(bounds.height - 71 - LayoutParameters.tabHeight - 1), width: (referenceView.bounds.width * (8/10)), height: referenceView.bounds.height - 150)
        layoutStripeView()
        layoutCollectionView()
        layoutTabView()
        setMask()
    }
    
    func layoutStripeView() {
        stripeView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 34)
        setStripeMask()
    }
    
    func layoutCollectionView() {
        collectionView.frame = CGRect(x: 0, y: stripeView.frame.maxY, width: bounds.width, height: bounds.height - LayoutParameters.tabHeight - stripeView.frame.maxY - 20)
    }
    
    func layoutTabView() {
        tabButton.frame = CGRect(x: 0, y: bounds.height - LayoutParameters.tabHeight, width: bounds.width/2, height: LayoutParameters.tabHeight)
    }
    
    func getPath(view: UIView) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint.zero)
        path.addLineToPoint(CGPoint(x: 0, y: view.bounds.height))
        path.addLineToPoint(CGPoint(x: view.bounds.width/2, y: view.bounds.height))
        path.addLineToPoint(CGPoint(x: view.bounds.width/2 + 20, y: view.bounds.height - LayoutParameters.tabHeight))
        path.addLineToPoint(CGPoint(x: view.bounds.width, y: view.bounds.height - LayoutParameters.tabHeight))
        path.addLineToPoint(CGPoint(x: view.bounds.width, y: 0))
        
        return path
    }
    
    func setMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = getPath(self).CGPath
        layer.mask = maskLayer
    }
    
    func setStripeMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = getPath(stripeView).CGPath
        stripeView.layer.mask = maskLayer
    }
    
    func setTitle(title: String) {
        tabButton.setTitle(title, forState: .Normal)
    }
}

extension PullTabView {
    
    func setupSnapBehavior(){
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(swipe)
    }
    
    
    func didPan(gesture: UIPanGestureRecognizer) {
        let navHeight = CGFloat(69)
        let detailLocation = gesture.locationInView(gesture.view)
        let location = gesture.locationInView(gesture.view!.superview)
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
            
            let collide = UICollisionBehavior(items: [self])
            collide.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x:0 , y: -(bounds.height - navHeight - LayoutParameters.tabHeight - 1)), toPoint: CGPoint(x:referenceView.bounds.maxX , y: -(bounds.height - navHeight - LayoutParameters.tabHeight)))
            collide.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x:0 , y: bounds.height + navHeight), toPoint: CGPoint(x:referenceView.bounds.maxX , y: bounds.height + navHeight))
            animator.addBehavior(collide)
            
            let offset = UIOffsetMake(0, location.y - center.y)
            attachment = UIAttachmentBehavior(item: gesture.view!, offsetFromCenter: offset, attachedToAnchor: CGPoint(x: center.x, y: location.y))
            attachment.length = 0
            attachment.frictionTorque = 0.0
            animator.addBehavior(attachment)
            
            let DB = UIDynamicItemBehavior(items: [self])
            DB.allowsRotation = false
            animator.addBehavior(DB)
            
        case .Changed:
            attachment.anchorPoint = CGPoint(x: center.x, y: location.y)
            
        case .Ended:
            animator.removeAllBehaviors()
            let velocity = gesture.velocityInView(gesture.view?.superview)
            let push = UIPushBehavior(items: [self], mode: .Instantaneous)
            push.pushDirection = CGVectorMake(0 , (velocity.y))
            push.magnitude = abs(velocity.y/10)
            animator.addBehavior(push)
            
            if velocity.y >= 1000 {
                grav.gravityDirection = CGVector(dx: 0, dy: 5)
            } else  if velocity.y <= -1000 {
                grav.gravityDirection = CGVector(dx: 0, dy: -5)
            } else if location.y >= 325{
                grav.gravityDirection = CGVector(dx: 0, dy: 5)
            } else {
                grav.gravityDirection = CGVector(dx: 0, dy: -5)
            }
            animator.addBehavior(grav)
            
            let collide = UICollisionBehavior(items: [self])
            //collide.translatesReferenceBoundsIntoBoundary = true
            collide.addBoundaryWithIdentifier("top", fromPoint: CGPoint(x:0 , y: -(bounds.height - navHeight - LayoutParameters.tabHeight - 1)), toPoint: CGPoint(x:referenceView.bounds.maxX , y: -(bounds.height - navHeight - LayoutParameters.tabHeight)))
            collide.addBoundaryWithIdentifier("bottom", fromPoint: CGPoint(x:0 , y: bounds.height + navHeight), toPoint: CGPoint(x:referenceView.bounds.maxX , y: bounds.height + navHeight))
            collide.addBoundaryWithIdentifier("left", fromPoint: CGPoint(x:-1 , y: -1000), toPoint: CGPoint(x: -1 , y: referenceView.bounds.maxX))
            collide.addBoundaryWithIdentifier("right", fromPoint: CGPoint(x:referenceView.bounds.width * (8/10) , y: 0), toPoint: CGPoint(x: referenceView.bounds.width * (8/10) , y: referenceView.bounds.maxX))
            animator.addBehavior(collide)
            
            let DB = UIDynamicItemBehavior(items: [self])
            DB.elasticity = 0
            DB.allowsRotation = false
            animator.addBehavior(DB)

        
        default:
            return
        }
        
    }
}
