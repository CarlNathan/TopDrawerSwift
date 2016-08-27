//
//  SendToTopDrawerViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 8/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD
import MobileCoreServices
import Material
import CloudKit

class SendToTopDrawerViewController: UIViewController {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var urlString: String?
    var webView: UIWebView? = UIWebView()
    
    let imageView = UIImageView()
    let textView = TextView()
    let hostLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationItem()
        
        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) in
                        let url = result as? NSURL
                        dispatch_async(dispatch_get_main_queue(), {
                            self.urlString = url?.absoluteString
                            
                            
                            self.webView!.delegate = self
                            let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                            hud.label.text = "Loading Preview"
                            self.webView!.loadRequest(NSURLRequest(URL: url!))
                        })
                    })
                }
                
            }
        }
        
    }
    
    func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func save() {
        
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.label.text = "Saving"
        
        let privateDB = CKContainer.init(identifier: "iCloud.Carl-Udren.TopDrawer").privateCloudDatabase
        
        let pageRecord = CKRecord(recordType: "Page")
        
        pageRecord["name"] = self.textView.text!
        pageRecord["date"] = NSDate()
        pageRecord["URLString"] = urlString
        pageRecord["hostName"] = hostLabel.text
        if let image = self.imageView.image {
            let data = UIImagePNGRepresentation(image)
            let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let path = directory.path! + "/\(self.textView.text).png"
            data!.writeToFile(path, atomically: false)
            pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        }
        
        privateDB.saveRecord(pageRecord) { (record, error) -> Void in
            if let e = error {
                print("Error Saving Page: \(e.localizedDescription)")
                dispatch_async(dispatch_get_main_queue(), {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
            })
        }
    }
    
    func setupView() {
        setupImageView()
        setupScrollView()
        setupHostLabel()
        setupTextView()
    }
    
    func setupNavigationItem() {
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(SendToTopDrawerViewController.done))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: #selector(SendToTopDrawerViewController.save))
        navItem.rightBarButtonItem?.enabled = false
    }
    
    func setupImageView() {
        imageView.contentMode = .ScaleAspectFill
        imageView.backgroundColor = UIColor.whiteColor()
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.borderWidth = 2
        imageView.clipsToBounds = true
        scrollView.addSubview(imageView)
    }
    func setupScrollView() {
        scrollView.alwaysBounceVertical = true
    }
    func setupHostLabel() {
        hostLabel.textColor = UIColor.redColor()
        hostLabel.font = RobotoFont.lightWithSize(13)
        hostLabel.numberOfLines = 2
        hostLabel.textAlignment = .Center
        scrollView.addSubview(hostLabel)
    }
    func setupTextView() {
        textView.placeholderLabel = UILabel()
        textView.placeholderLabel!.textColor = MaterialColor.grey.base
        textView.placeholderLabel!.text = "Title"
        
        textView.titleLabel = UILabel()
        textView.titleLabel!.font = RobotoFont.mediumWithSize(12)
        textView.titleLabelColor = MaterialColor.grey.base
        textView.titleLabelActiveColor = MaterialColor.blue.accent3
        
        textView.backgroundColor = UIColor.clearColor()
        textView.textColor = UIColor.blackColor()
        textView.scrollEnabled = false
        textView.font = UIFont.systemFontOfSize(16)
        scrollView.addSubview(textView)
    }
    
    override func viewDidLayoutSubviews() {
        layoutTextView()
        layoutImageView()
        layoutHostLabel()
    }
    
    
    func layoutTextView() {
        textView.frame = CGRect(x: 20, y: 40, width: view.bounds.width/2 - 20, height: 200)
    }
    func layoutImageView() {
        imageView.frame = CGRect(x: textView.frame.maxX + 5, y: 20, width: view.bounds.width/2 - 20, height: view.bounds.width/2 - 10)
    }
    func layoutHostLabel() {
        hostLabel.frame = CGRect(x: textView.frame.maxX, y: imageView.frame.maxY, width: imageView.bounds.width, height: 40)
    }
    
}

extension SendToTopDrawerViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        if !webView.loading {
            webView.stopLoading()
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
            self.textView.text = title
            
            //webView.frame = CGRect(x: 0, y: 0, width: webView.intrinsicContentSize().width, height: webView.intrinsicContentSize().height)
            webView.frame = self.view.bounds
            //webView.scrollView.contentSize
            UIGraphicsBeginImageContext(webView.bounds.size)
            webView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            self.imageView.image = image
            
            let host = webView.stringByEvaluatingJavaScriptFromString("document.location.hostname")
            self.hostLabel.text = host
            
            self.webView = nil
            textView.becomeFirstResponder()

            self.navItem.rightBarButtonItem?.enabled = true
        }
    }
}

