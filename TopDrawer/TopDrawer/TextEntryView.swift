//
//  TextEntryView.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/21/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol TextEntryViewDelegate {
    func textDidChange(text: String)
}

class TextEntryView: UIView {
    let textField = TextField()
    var delegate: TextEntryViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    func setupTextField() {
        textField.placeholder = "New Catagory Name"
        textField.backgroundColor = UIColor.clearColor()
        textField.placeholderTextColor = MaterialColor.blue.accent1
        textField.textColor = MaterialColor.grey.darken1
        textField.tintColor = MaterialColor.blue.accent1
        
        //clear Button
//        let clearButton = RaisedButton()
//        clearButton.backgroundColor = MaterialColor.red.darken3
//        clearButton.setImage(UIImage(named: "cm_close_white"), forState: .Normal)
//        clearButton.pulseColor = MaterialColor.blue.accent1
//        textField.clearButton = clearButton
//        textField.clearButtonMode = .Always
//        textField.rightViewMode = .Always
        
        
        //TitleLabel
        let titleLabel = UILabel()
        titleLabel.font = RobotoFont.lightWithSize(12)
        textField.titleLabel = titleLabel
        textField.titleLabelColor = MaterialColor.blue.accent1
        textField.titleLabelActiveColor = MaterialColor.blue.accent1
        
        //detail label
        
        //underline
        textField.bottomBorderColor = MaterialColor.blue.accent1
        textField.bottomBorderTitleActiveColor = MaterialColor.blue.accent1
        

        textField.delegate = self
        addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    override func layoutSubviews() {
        layoutTextField()
    }
    
    func layoutTextField() {
        textField.frame = CGRect(x: 20, y: 50, width: bounds.width - 40, height: 30)
    }
}

extension TextEntryView: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let d = delegate {
            let nsString = textField.text! as NSString
            let newString = nsString.stringByReplacingCharactersInRange(range, withString: string)
            let s = String(newString)
            d.textDidChange(s)
        }
        return true
    }
}


