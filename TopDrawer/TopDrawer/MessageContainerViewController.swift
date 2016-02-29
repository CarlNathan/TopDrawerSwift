//
//  MessageContainerViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class MessageContainerViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    var tabBar: TopicTabBarController?
    var topic: Topic?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.segmentedControl.addTarget(self, action: "segmentedControlDidChangeValue", forControlEvents: .ValueChanged)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
