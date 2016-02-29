//
//  File.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class DetailViewContoller: UIViewController, UIScrollViewDelegate, UIWebViewDelegate, WKNavigationDelegate {
    
    var URLString: String!
    var lastScrolOffset = CGFloat.init(integerLiteral: 0)
    @IBOutlet weak var webView: UIWebView!
    var webKitView: WKWebView!
 
    
    override func viewDidLoad() {
        
        let URL = NSURL(string: URLString)
        let request = NSURLRequest(URL: URL!)
        webView.loadRequest(request)
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        let saveButton = UIBarButtonItem(title: "Share", style: .Plain, target: self, action: "sharePage")
        self.navigationItem.rightBarButtonItem = saveButton

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y - lastScrolOffset) > 0 {
            self.navigationController!.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController!.setNavigationBarHidden(false, animated: true)
        }
        lastScrolOffset = scrollView.contentOffset.y
    }
    
    func sharePage () {
        let share = UIActivityViewController(activityItems: [(self.webView.request?.URL)!], applicationActivities: nil)
        presentViewController(share, animated: true) { () -> Void in
            //completion
        }
    }
    
}
