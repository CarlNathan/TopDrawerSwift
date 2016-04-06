//
//  CustomTextField.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/28/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material


class CustomTextField: TextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        backgroundColor = MaterialColor.clear
        placeholder = title
        placeholderTextColor = MaterialColor.blue.accent1
        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel!.font = RobotoFont.mediumWithSize(12)
        titleLabel?.textColor = MaterialColor.blue.accent1
        titleLabelActiveColor = MaterialColor.blue.accent1
        titleLabelColor = MaterialColor.blue.accent1
        font = RobotoFont.regularWithSize(14)
        textColor = MaterialColor.grey.darken2
        bottomBorderColor = MaterialColor.blue.accent1
        returnKeyType = .Done
        
        let image = UIImage(named: "App Downloads (2)")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let clearButton: FlatButton = FlatButton()
        clearButton.pulseColor = MaterialColor.grey.base
        clearButton.pulseScale = false
        clearButton.tintColor = MaterialColor.grey.base
        clearButton.borderColor = MaterialColor.blue.base
        clearButton.setImage(image, forState: .Normal)
        clearButton.setImage(image, forState: .Highlighted)
        clearButton.setTitle("Clear", forState: .Normal)
        clearButton.setTitleColor(MaterialColor.blue.accent1, forState: .Normal)

        self.clearButton = clearButton

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
