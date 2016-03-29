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
        placeholderTextColor = MaterialColor.blue.base
        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel!.font = RobotoFont.mediumWithSize(12)
        titleLabel?.textColor = MaterialColor.blue.accent1
        titleLabelActiveColor = MaterialColor.blue.accent1
        titleLabelColor = MaterialColor.blue.accent1
        font = RobotoFont.regularWithSize(20)
        textColor = MaterialColor.white
        bottomBorderColor = MaterialColor.blue.accent1
        
        let image = UIImage(named: "ic_close_white")?.imageWithRenderingMode(.AlwaysTemplate)
        
        let clearButton: FlatButton = FlatButton()
        clearButton.pulseColor = MaterialColor.grey.base
        clearButton.pulseScale = false
        clearButton.tintColor = MaterialColor.grey.base
        clearButton.setImage(image, forState: .Normal)
        clearButton.setImage(image, forState: .Highlighted)
        self.clearButton = clearButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
