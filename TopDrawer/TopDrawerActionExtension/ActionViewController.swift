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

class ActionViewController: UIViewController {

    
    var URLString: String!
    var imageString: String!
    let imageView = UIImageView()
    let imageCardView: ImageCardView = ImageCardView()
    let detailView = DetailView(frame: CGRectMake(0,0,500,500))
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var blurLayer: UIVisualEffectView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupKeyboardNotifications()
        setupCardView()
    
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
                                self.detailView.descriptionView.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["description"] as! String
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
        if let image = self.imageView.image {
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
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    func setupView(){
        
    }
    
    func setupCardView(){
        // Image.
        let size: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - CGFloat(40), 80)
        imageCardView.image = UIImage.imageWithColor(MaterialColor.deepOrange.darken1, size: size)
        imageCardView.maxImageHeight = 100
        
        // Title label.
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "TopDrawer.Save Page"
        titleLabel.textColor = MaterialColor.white
        titleLabel.font = RobotoFont.mediumWithSize(18)
        imageCardView.titleLabel = titleLabel
        imageCardView.titleLabelInset.top = 50
        
        // Detail label.
        imageCardView.detailView = detailView
        imageView.backgroundColor = UIColor.redColor()
        imageCardView.detailViewInset.top = 30
        
        // Yes button.
        let btn1 = RaisedButton()
        btn1.backgroundColor = MaterialColor.blue.accent1
        btn1.pulseColor = MaterialColor.white
        btn1.pulseScale = false
        btn1.setTitle("      SAVE      ", forState: .Normal)
        btn1.setTitleColor(MaterialColor.white, forState: .Normal)
        btn1.addTarget(self, action: #selector(save), forControlEvents: .TouchUpInside)
        
        // No button.
        let btn2: FlatButton = FlatButton()
        btn2.pulseColor = MaterialColor.blue.accent1
        btn2.backgroundColor = MaterialColor.white
        btn2.depth = .Depth1
        btn2.pulseScale = false
        btn2.setTitle("CANCEL", forState: .Normal)
        btn2.setTitleColor(MaterialColor.blue.accent1, forState: .Normal)
        btn2.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)

        
        // Add buttons to left side.
        imageCardView.leftButtons = [btn2]
        imageCardView.rightButtons = [btn1]
        
        // To support orientation changes, use MaterialLayout.
        view.addSubview(imageCardView)
        
    }
    
    override func viewDidLayoutSubviews() {
        
        imageCardView.translatesAutoresizingMaskIntoConstraints = false
        MaterialLayout.alignToParentHorizontally(view, child: imageCardView, left: 20, right: 20)
        MaterialLayout.alignFromTop(view, child: imageCardView, top: 70)
        MaterialLayout.alignFromBottom(view, child: imageCardView, bottom: 100)
        

    }
    
    func setupKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardDidHide), name: UIKeyboardDidHideNotification, object: nil)
    }
    
    func keyboardDidShow(){
        previousDetailFrame = self.detailView.frame
        detailView.removeFromSuperview()
        view.addSubview(detailView)
        UIView.animateWithDuration(0.5) {
            self.detailView.backgroundColor = MaterialColor.white
            self.detailView.frame = self.imageCardView.frame
        }
    }
    
    var previousDetailFrame: CGRect?
    
    func keyboardDidHide(){
        detailView.removeFromSuperview()
        imageCardView.detailView = detailView
        UIView.animateWithDuration(0.5) {
            self.detailView.backgroundColor = MaterialColor.clear
            self.detailView.frame = self.previousDetailFrame!
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detailView.titleField.resignFirstResponder()
        detailView.descriptionView.resignFirstResponder()
    }
}
