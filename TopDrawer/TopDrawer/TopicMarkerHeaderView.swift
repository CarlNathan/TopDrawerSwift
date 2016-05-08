//
//  TopicMarkerHeaderView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/18/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material
import CloudKit

class TopicMarkerHeaderView: UICollectionReusableView {
    
    let imageGrad = CAGradientLayer()
    let messageFadeGrad = CAGradientLayer()
    var page: Page? {
        didSet {
            imageView.image = page!.image
            titleLabel.text = page!.name
        }
    }
    let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
    let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageGrad.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        messageFadeGrad.colors = [UIColor.whiteColor().CGColor, UIColor(white: 1, alpha: 0).CGColor]
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        titleLabel.textColor = UIColor.whiteColor()
        imageView.layer.addSublayer(imageGrad)
        layer.addSublayer(messageFadeGrad)
        addSubview(imageView)
        addSubview(titleLabel)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        imageView.frame = CGRect(x:(bounds.size.width*0.05), y: 0, width: (bounds.size.width*0.9), height: bounds.size.height)
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        imageGrad.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        messageFadeGrad.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height + 20)
    }
    
    override func prepareForReuse() {
        //imageView.image = nil
        //titleLabel.text = nil
    }
    
    func getPageForID(pageID: CKRecordID) {
        InboxManager.sharedInstance.getPageForID(pageID) { (page) in
            self.page = page
        }
    }
}

