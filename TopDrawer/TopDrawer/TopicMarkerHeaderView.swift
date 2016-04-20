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
    
    let grad = CAGradientLayer()
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
        grad.colors = [UIColor.clearColor().CGColor, UIColor.blackColor().CGColor]
        layer.cornerRadius = 10
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        titleLabel.textColor = UIColor.whiteColor()
        imageView.layer.addSublayer(grad)
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
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        grad.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    override func prepareForReuse() {
        imageView.image = nil
        titleLabel.text = nil
    }
    
    func getPageForID(pageID: CKRecordID) {
        InboxManager.sharedInstance.getPageForID(pageID) { (page) in
            self.page = page
        }
    }
}

