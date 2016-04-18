//
//  MessageContainerViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import SafariServices
import CloudKit


class MessageContainerViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    var tabBar: TopicTabBarController?
    var topic: Topic?
    var topicMarkers = [TopicMarker]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.addTarget(self, action: #selector(segmentedControlDidChangeValue), forControlEvents: .ValueChanged)

        // Do any additional setup after loading the view.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newTopicMarker), name: "NewTopicMarker", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTopicMarkerDown), name: "ScrollDown", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTopicMarkerUp), name: "ScrollUp", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newRemoteTopicMarker), name: "RemoteMarker", object: nil)
        getTopicMarkers()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateTopicMarkerDown(sender: NSNotification) {
        let date = sender.userInfo!["date"]as! NSDate
        for marker in topicMarkers {
            //date is less than date of marker
            if date.compare(marker.date!) == NSComparisonResult.OrderedAscending {
                InboxManager.sharedInstance.getPageForID(marker.page!, completionHandler: { (page) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setTopicMarker(page!)
                    })
                })
                return
            }
        }
    }
    func updateTopicMarkerUp(sender: NSNotification) {
        let date = sender.userInfo!["date"]as! NSDate
        for marker in topicMarkers {
            //date is greater than date of marker
            if date.compare(marker.date!) == NSComparisonResult.OrderedDescending {
                InboxManager.sharedInstance.getPageForID(marker.page!, completionHandler: { (page) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setTopicMarker(page!)
                    })
                })
                return
            }
        }
    }

    
    func newTopicMarker(sender:NSNotification) {
        //just set to current
        let marker = sender.userInfo!["marker"] as! TopicMarker
        self.topicMarkers.append(marker)
        if self.topicMarkers.count > 1 {
            self.topicMarkers.sortInPlace({ (a, b) -> Bool in
                a.date!.compare(b.date!) == NSComparisonResult.OrderedDescending
            })
        }
        InboxManager.sharedInstance.getPageForID(marker.page!) { (page) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setTopicMarker(page!)

            })
        }
    }
    
    func newRemoteTopicMarker(sender:NSNotification) {
        let recordID = sender.userInfo!["topicID"] as! CKRecordID
        InboxManager.sharedInstance.getTopicMarkerForID(recordID) { (marker) -> Void in
            
            self.topicMarkers.append(marker!)
            InboxManager.sharedInstance.getPageForID(marker!.page!) { (page) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.setTopicMarker(page!)
                    
                })

            }
        }
    }
    
    var buttonURL: String?
    func setTopicMarker (page:Page) {
        let image = page.image
        let imageButton = UIButton(type: .Custom)
        imageButton.addTarget(self, action: #selector(buttonWasPressed), forControlEvents: .TouchUpInside)
        imageButton.bounds = CGRectMake(0, 0, 20, 20)
        imageButton.setImage(image, forState: .Normal)
        let barButton = UIBarButtonItem(customView: imageButton)
        self.navigationItem.rightBarButtonItem = barButton
        self.navigationItem.title = page.name
        self.buttonURL = page.URLString
    
    }
    
    func buttonWasPressed() {
        let URLString = buttonURL
        let sfc = SFSafariViewController(URL: NSURL(string: URLString!)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func segmentedControlDidChangeValue () {
        self.tabBar?.selectedIndex = self.segmentedControl.selectedSegmentIndex
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.tabBar = segue.destinationViewController as? TopicTabBarController
        self.tabBar!.tabBar.hidden = true
        self.tabBar!.topic = self.topic        
    }
    
    func getTopicMarkers () {
        InboxManager.sharedInstance.getTopicMarkers(self.topic!) { (topics) -> Void in
            self.topicMarkers = topics!
            if self.topicMarkers.count > 1 {
                self.topicMarkers.sortInPlace({ (a, b) -> Bool in
                    a.date!.compare(b.date!) == NSComparisonResult.OrderedAscending
            })
            }
            if let marker = self.topicMarkers.last {
                InboxManager.sharedInstance.getPageForID(marker.page!, completionHandler: { (page) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.setTopicMarker(page!)
                    })
                    //self.currentIndex
                })
            }
        }
    }
}

