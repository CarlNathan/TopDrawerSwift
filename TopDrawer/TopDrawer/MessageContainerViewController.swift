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
        self.tabBar!.topic = topic
    }
    
}

