//
//  CustomTextView.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/28/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material

class CustomTextView: TextView {
    
    init(frame: CGRect){
        super.init(frame: frame, textContainer: nil)
    }
    
    convenience init(frame: CGRect, title: String) {
        self.init(frame: frame)
        backgroundColor = MaterialColor.clear
        placeholderLabel = UILabel()
        placeholderLabel?.text = title
        placeholderLabel?.textColor = MaterialColor.blue.accent1
        placeholderLabel?.font = RobotoFont.regularWithSize(14)
        titleLabel = UILabel()
        titleLabel?.text = title
        titleLabel!.font = RobotoFont.mediumWithSize(12)
        titleLabel?.textColor = MaterialColor.blue.accent1
        titleLabelActiveColor = MaterialColor.blue.accent1
        font = RobotoFont.regularWithSize(14)
        textColor = MaterialColor.grey.darken2
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}