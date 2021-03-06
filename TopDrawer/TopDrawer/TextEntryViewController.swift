//
//  TextEntryViewController.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/16/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material

class TextEntryViewController: UIViewController, UITextViewDelegate {

    let textView = TextView()
    let backButton = FlatButton()
    var placeholder: String!
    var content: String? {
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                self.textView.text = self.content
                self.backButton.enabled = true
            }
        }
    }
    
    init(placeholder: String) {
        super.init(nibName: nil, bundle: nil)
        self.placeholder = placeholder
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.hidden = true
        view.backgroundColor = MaterialColor.white
        setupBackButton()
        setupTextView()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTextView() {
        
        textView.backgroundColor = MaterialColor.clear
        textView.placeholderLabel = UILabel()
        textView.placeholderLabel?.text = placeholder
        textView.placeholderLabel?.textColor = MaterialColor.blue.accent1
        textView.placeholderLabel?.font = RobotoFont.regularWithSize(18)
        textView.titleLabel = UILabel()
        textView.titleLabel?.text = placeholder
        textView.titleLabel!.font = RobotoFont.mediumWithSize(16)
        textView.titleLabel?.textColor = MaterialColor.blue.accent1
        textView.titleLabelActiveColor = MaterialColor.blue.accent1
        textView.font = RobotoFont.regularWithSize(18)
        textView.textColor = MaterialColor.grey.darken2
        textView.returnKeyType = .Done
        textView.userInteractionEnabled = true
        view.userInteractionEnabled = true
        //textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.delegate = self
        textView.inputAccessoryView = backButton
        view.addSubview(textView)
        textView.becomeFirstResponder()
        
    }
    
    func setupBackButton () {
        backButton.setTitle("Cannot be Blank", forState: .Disabled)
        backButton.setTitle("Done", forState: .Normal)
        backButton.pulseColor = MaterialColor.blue.base
        backButton.backgroundColor = MaterialColor.clear
        backButton.tintColor = MaterialColor.blue.base
        backButton.addTarget(self, action: #selector(backButtonPressed), forControlEvents: .TouchUpInside)
        backButton.enabled = false
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        backButton.contentScaleFactor = 10
        backButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //view.addSubview(backButton)
    }
    
    override func viewDidLayoutSubviews() {
        let viewSize = view.frame.size
        textView.frame = CGRectMake(20,40,viewSize.width - 20, viewSize.height - 40)
        
    }

    func backButtonPressed(){
        let notificationName = placeholder+"WasSet"
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: ["text":textView.text])
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.hasText() {
            backButton.enabled = true
        } else {
            backButton.enabled = false

        }
    }
}
