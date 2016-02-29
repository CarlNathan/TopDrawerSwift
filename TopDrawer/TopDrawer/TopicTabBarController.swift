//
//  TopicTabBarController.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/27/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit

class TopicTabBarController: UITabBarController {
    
    var topic: Topic?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
