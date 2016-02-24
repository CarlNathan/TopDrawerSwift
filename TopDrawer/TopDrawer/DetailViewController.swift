//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class DetailViewContoller: UIViewController {
    
    var URLString: String!
    @IBOutlet weak var webView: UIWebView!
 
    
    override func viewDidLoad() {
        
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.bounces = false

    }
    
}
