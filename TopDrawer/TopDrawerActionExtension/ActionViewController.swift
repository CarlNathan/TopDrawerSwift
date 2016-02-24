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

class ActionViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var URLString: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    
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
                                self.nameTextField.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["title"] as? String
//                                self.nameTextField.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["host"] as! String
                                self.descriptionTextView.text = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["description"] as! String
//                            self.articleImage = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["image"] as! String
                                self.URLString = resultDict[NSExtensionJavaScriptPreprocessingResultsKey]!["url"] as! String
                                
                                
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

    @IBAction func save(sender: AnyObject) {
        
        let privateDB = CKContainer.init(identifier: "iCloud.Carl-Udren.TopDrawer").publicCloudDatabase
        
        let pageID = CKRecordID(recordName: self.nameTextField.text!)
        let pageRecord = CKRecord(recordType: "Page", recordID: pageID)
        
        pageRecord["description"] = self.description
        pageRecord["date"] = NSDate()
        pageRecord["URLString"] = URLString
        
        
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
//            do{
//                try NSFileManager.defaultManager().removeItemAtPath(path)
//            } catch _ {
//                //handle error
//            }
            
        }
        
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }
    @IBAction func cancel() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}
