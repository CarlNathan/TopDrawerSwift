//
//  DetailView.swift
//  TopDrawer
//
//  Created by Carl Udren on 3/30/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class DetailView: MaterialView {
    var titleField: CustomTextField!
    var descriptionView: CustomTextView!
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        titleField = CustomTextField(frame: CGRectMake(0, 0, 0, 0), title: "Title")
        self.addSubview(titleField)
        descriptionView = CustomTextView(frame: CGRectMake(0,0,0,0), title: "Description")
        self.addSubview(descriptionView)
        self.backgroundColor = MaterialColor.clear
        self.cornerRadius = 3
    }
    
    override func layoutSubviews() {
        let size = self.bounds
        let margin = CGFloat(10)
        let titleHeight = CGFloat (20)
        let verticalSpacing = CGFloat(30)
        titleField.frame = CGRectMake(margin, verticalSpacing, size.width - 2*margin, titleHeight)
        descriptionView.frame = CGRectMake(margin, 2*verticalSpacing + titleHeight, size.width - 2*margin, size.height-2*verticalSpacing-titleHeight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}