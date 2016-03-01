//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class DetailViewContoller: UIViewController, SFSafariViewControllerDelegate {
    
    var URLString: String!
    var webKitView: SFSafariViewController!
 
    
    override func viewDidLoad() {
        
        let sfc = SFSafariViewController(URL: NSURL(string: URLString)!)
        sfc.delegate = self
        presentViewController(sfc, animated: true, completion: nil)
    }
    
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}