//
//  EmptyPageView.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/24/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class EmptyPageView: UIView {
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupImageView()
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground() {
        backgroundColor = UIColor.whiteColor()
    }
    
    func setupImageView() {
        imageView.contentMode = .ScaleToFill
        imageView.image = UIImage(named: "Stack of Photos-96")?.imageWithRenderingMode(.AlwaysTemplate)
        imageView.tintColor = MaterialColor.grey.darken3
        addSubview(imageView)
    }
    
    func setupLabel() {
        label.text = "There are no pages to display."
        label.font = RobotoFont.boldWithSize(16)
        label.textColor = MaterialColor.grey.darken3
        label.numberOfLines = 2
        label.textAlignment = .Center
        addSubview(label)
    }
    
    override func layoutSubviews() {
        layoutImageView()
        layoutLabel()
    }
    
    func layoutImageView() {
        imageView.frame = CGRect(x: 3*bounds.width/8, y: 3*bounds.height/8, width: bounds.width/4, height: bounds.width/4)
    }
    
    func layoutLabel() {
        label.frame = CGRect(x: 20, y: imageView.frame.maxY + 20, width: bounds.width - 40, height: 40)
    }
}