//
//  ActionViewController.swift
//  TopDrawerActionExtension
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import MobileCoreServices
import CloudKit
import Material

class ActionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    
    var URLString: String!
    var imageString: String!
    let imageCardView: ImageCardView = ImageCardView()
    let detailView = DetailView(frame: CGRectMake(0,0,500,500))
    let webView = UIWebView()
    lazy var animator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: self.view)
    }()
    var attachment: UIAttachmentBehavior!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var blurLayer: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDetailView()
        setupCardView()
        setupCardViewSnapBehavior()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        for item: AnyObject in (self.extensionContext?.inputItems)! {
            let inputItem = item as! NSExtensionItem
            
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) -> Void in
                        if let resultDict = result as? NSDictionary {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.detailView.titleField.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["title"] as? String ?? ""
//                                self.nameTextField.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["host"] as! String
                                self.detailView.descriptionView.text = (resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["url"] as! String + (resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["image"] as! String))
                            self.imageString = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["image"] as? String
                                self.URLString = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["url"] as! String
                                
                                let session = NSURLSession.sharedSession()
                                if let string = self.imageString {
                                    let URL = NSURL(string: string)
                                    let request = NSURLRequest(URL: URL!)
                                    let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
                                        if let e = error {
                                        print("Error Saving Image: \(e.localizedDescription)")
                                        return
                                        }
                                        let image = UIImage(data: data!)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            self.backgroundImage.image = image
                                            self.imageCardView.image = image

                                        })
                                    }
                                    task.resume()
                                
                                }
                            })
                        }
                    })
                }
                
                
                if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                    itemProvider.loadItemForTypeIdentifier(kUTTypeURL as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) in
                        let url = result as? NSURL
                        dispatch_async(dispatch_get_main_queue(), {
                            self.detailView.titleField.text = url?.absoluteString
                            
                            self.webView.delegate = self
                            self.webView.loadRequest(NSURLRequest(URL: url!))
                        })
                    })
                }
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    itemProvider.loadItemForTypeIdentifier(kUTTypeImage as String, options: nil, completionHandler: { (result: NSSecureCoding?, error: NSError!) in
                        self.imageCardView.image = result as? UIImage
                    })
                }
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func save() {
        
        let privateDB = CKContainer.init(identifier: "iCloud.Carl-Udren.TopDrawer").privateCloudDatabase
        
        let pageRecord = CKRecord(recordType: "Page")
        
        pageRecord["name"] = self.detailView.titleField.text!
        pageRecord["description"] = self.detailView.descriptionView.text
        pageRecord["date"] = NSDate()
        pageRecord["URLString"] = URLString
        if let image = self.backgroundImage.image {
            let data = UIImagePNGRepresentation(image)
            let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let path = directory.path! + "/\(self.detailView.titleField.text).png"
            data!.writeToFile(path, atomically: false)
            pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        }
        
        
        //let data = UIImagePNGRepresentation(self.image!)
        //let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
     //   let path = directory.path! + "/\(self.name).png"
       // data!.writeToFile(path, atomically: false)
       // pageRecord["image"] = CKAsset(fileURL: NSURL(fileURLWithPath: path))
        
        privateDB.saveRecord(pageRecord) { (record, error) -> Void in
            if let e = error {
                print("Error Saving Page: \(e.localizedDescription)")
                return
            }
        }
        
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    func cancel() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(nil, completionHandler: nil)
    
    }
    
    func setupDetailView(){
        let doneButton = FlatButton(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.addTarget(self, action: #selector(dismissKeyboard), forControlEvents: .TouchUpInside)
        doneButton.tintColor = MaterialColor.blue.accent1
        detailView.descriptionView.delegate = self
        detailView.titleField.delegate = self
        detailView.descriptionView.inputAccessoryView = doneButton
        detailView.titleField.inputAccessoryView = doneButton

    }
    func setupCardView(){
        // Image.
        let size: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - CGFloat(40), 80)
        imageCardView.image = UIImage.imageWithColor(MaterialColor.deepOrange.darken1, size: size)
        imageCardView.maxImageHeight = 100
        imageCardView.imageLayer!.contentsGravity = kCAGravityResizeAspectFill
        
        // Title label.
        
        
        // Detail label.
        imageCardView.detailView = detailView
        imageCardView.detailViewInset.top = 30
        
        // Yes button.
        let btn1 = FlatButton()
        btn1.backgroundColor = MaterialColor.clear
        btn1.pulseColor = MaterialColor.blue.accent1
        btn1.pulseScale = false
        btn1.setTitle("      SAVE      ", forState: .Normal)
        btn1.setTitleColor(MaterialColor.blue.accent1, forState: .Normal)
        btn1.titleLabel!.font = RobotoFont.lightWithSize(16)
        btn1.addTarget(self, action: #selector(save), forControlEvents: .TouchUpInside)
        
        // No button.
        let btn2: FlatButton = FlatButton()
        btn2.pulseColor = MaterialColor.red.accent1
        btn2.backgroundColor = MaterialColor.clear
        btn2.pulseScale = false
        btn2.setTitle("  CANCEL  ", forState: .Normal)
        btn2.titleLabel!.font = RobotoFont.lightWithSize(16)
        btn2.setTitleColor(MaterialColor.red.accent1, forState: .Normal)
        btn2.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)

        
        // Add buttons to left side.
        imageCardView.leftButtons = [btn2]
        imageCardView.rightButtons = [btn1]
        
        // To support orientation changes, use MaterialLayout.
        imageCardView.frame = view.frame
        view.addSubview(imageCardView)
        
    }
    
    func setupCardViewSnapBehavior(){
        
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        imageCardView.addGestureRecognizer(swipe)
    }
    
    override func viewDidLayoutSubviews() {

        imageCardView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignToParentHorizontally(view, child: imageCardView, left: 20, right: 20)
        MaterialLayout.alignFromTop(view, child: imageCardView, top: 70)
        MaterialLayout.alignFromBottom(view, child: imageCardView, bottom: 100)

    }
    
    func didPan(gesture: UIPanGestureRecognizer) {
        let detailLocation = gesture.locationInView(gesture.view!)
        let location = gesture.locationInView(gesture.view!.superview)
        switch gesture.state {
        case .Began:
            animator.removeAllBehaviors()
            let offset = UIOffsetMake(detailLocation.x - CGRectGetMidX(detailView.bounds), detailLocation.y - CGRectGetMidY(detailView.bounds))
            attachment = UIAttachmentBehavior(item: gesture.view!, offsetFromCenter: offset, attachedToAnchor: location)
            attachment.length = 10
            attachment.frictionTorque = 0.05
            
            animator.addBehavior(attachment)
            if let cancel = imageCardView.leftButtons![0] as? FlatButton {
                cancel.pulse()
            }
            if let save = self.imageCardView.rightButtons![0] as? FlatButton {
                save.pulse()
            }
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detailView.titleField.resignFirstResponder()
        detailView.descriptionView.resignFirstResponder()
    }
    
    func dismissKeyboard(){
        detailView.titleField.resignFirstResponder()
        detailView.descriptionView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        animator.removeAllBehaviors()
        let snap = UISnapBehavior(item: imageCardView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y - 80))
        animator.addBehavior(snap)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        animator.removeAllBehaviors()
        let snap = UISnapBehavior(item: imageCardView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y))
        animator.addBehavior(snap)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        animator.removeAllBehaviors()
        let snap = UISnapBehavior(item: imageCardView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y - 80))
        animator.addBehavior(snap)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        animator.removeAllBehaviors()
        let snap = UISnapBehavior(item: imageCardView, snapToPoint: CGPoint(x: view.center.x, y: view.center.y))
        animator.addBehavior(snap)
    }
}

extension ActionViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        if !webView.loading {
            let title = webView.stringByEvaluatingJavaScriptFromString("document.title")
            self.detailView.descriptionView.text = title
        
            webView.frame = view.bounds
            UIGraphicsBeginImageContext(webView.bounds.size)
            webView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
        
            self.imageCardView.image = image
        }
    }
}

