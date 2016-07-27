//
//  PageCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 7/21/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

protocol PageCollectionViewCellDelegate {
    func deleteButtonPressed(page: Page)
    func shareButtonPressed(page: Page)
    func topicButtonPressed(page: Page)
}

class PageCollectionViewCell: UICollectionViewCell {
    
    var page: Page?
    var delegate: PageCollectionViewCellDelegate?
    let imageView = UIImageView()
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let dateFormatter = NSDateFormatter()
    let hostLabel = UILabel()
    let alphaLayer = CALayer()
    let deleteButton = FlatButton()
    let shareButton = FlatButton()
    let topicButton = FlatButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupAlphaLayer()
        setupDateLabel()
        setupDateFormatter()
        setupTitleLabel()
        setupHostLabel()
        setupDeleteButton()
        setupShareButton()
        setupTopicButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageView()
        setupAlphaLayer()
        setupDateLabel()
        setupDateFormatter()
        setupTitleLabel()
        setupHostLabel()
        setupDeleteButton()
        setupShareButton()
        setupTopicButton()
    }
    
    func configureCell(page: Page) {
        backgroundColor = MaterialColor.grey.lighten3
        self.page = page
        imageView.image = page.image ?? UIImage(named: "cm_image_white")
        dateLabel.text = dateFormatter.stringFromDate(page.date!)
        titleLabel.text = page.name
        layoutSubviews()
    }
    
    override func prepareForReuse() {
        //
    }
    
    func setupImageView() {
        imageView.contentMode = .ScaleAspectFill
        imageView.backgroundColor = MaterialColor.grey.base
        imageView.layer.masksToBounds = true
        addSubview(imageView)
    }
    
    func setupTitleLabel() {
        titleLabel.font = RobotoFont.lightWithSize(14)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.numberOfLines = 3
        addSubview(titleLabel)
    }
    
    func setupDateFormatter() {
        dateFormatter.dateFormat = "MM/dd/yyyy"
    }
    
    func setupDateLabel() {
        dateLabel.textColor = MaterialColor.grey.base
        dateLabel.font = RobotoFont.lightWithSize(10)
        dateLabel.text = "some date"
        addSubview(dateLabel)
    }
    
    func setupHostLabel() {
        hostLabel.textColor = MaterialColor.red.darken2
        hostLabel.font = RobotoFont.lightWithSize(10)
        hostLabel.text = "www.whatever.com"
        addSubview(hostLabel)
    }
    
    func setupAlphaLayer() {
        alphaLayer.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.3).CGColor
        imageView.layer.addSublayer(alphaLayer)
    }
    
    func setupDeleteButton() {
        deleteButton.backgroundColor = MaterialColor.red.base
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(deleteButton)
    }
    
    func setupShareButton() {
        shareButton.backgroundColor = MaterialColor.blue.base
        shareButton.addTarget(self, action: #selector(shareButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(shareButton)
    }
    
    func setupTopicButton() {
        topicButton.backgroundColor = MaterialColor.orange.base
        topicButton.addTarget(self, action: #selector(topicButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(topicButton)
    }
    
    override func layoutSubviews() {
        layoutImageView()
        layoutDateLabel()
        layoutTitleLabel()
        layoutHostLabel()
        layoutDeleteButton()
        layoutShareButton()
        layoutTopicButton()
    }
    
    func layoutImageView() {
        imageView.frame = CGRect(x: 0, y: 0, width: bounds.height, height: bounds.height)
        alphaLayer.frame = imageView.bounds
    }
    
    func layoutDateLabel() {
        dateLabel.frame = CGRect(x: imageView.frame.maxX + 20, y: 10, width: bounds.width - imageView.frame.maxX, height: 10)
    }
    
    func layoutTitleLabel() {
        titleLabel.frame = CGRect(x: imageView.frame.maxX + 20, y: dateLabel.frame.maxY + 5, width: bounds.width - imageView.frame.maxX - 40, height: 35)
        //titleLabel.sizeToFit()
    }
    
    func layoutHostLabel() {
        hostLabel.frame = CGRect(x: imageView.frame.maxX + 20, y: titleLabel.frame.maxY + 5, width: bounds.width - imageView.frame.maxX, height: 10)
    }
    
    func layoutDeleteButton() {
        deleteButton.frame = CGRect(x: imageView.frame.maxX + 20, y: hostLabel.frame.maxY + 10, width: ((bounds.width - imageView.frame.maxX - 60) / 3), height: 30)
    }
    
    func layoutShareButton() {
        shareButton.frame = CGRect(x: deleteButton.frame.maxX + 10, y: hostLabel.frame.maxY + 10, width: ((bounds.width - imageView.frame.maxX - 60) / 3), height: 30)
    }
    
    func layoutTopicButton() {
        topicButton.frame = CGRect(x: shareButton.frame.maxX + 10, y: hostLabel.frame.maxY + 10, width: ((bounds.width - imageView.frame.maxX - 60) / 3), height: 30)
    }
    
    func deleteButtonPressed() {
        delegate?.deleteButtonPressed(page!)
    }
    
    func shareButtonPressed() {
        delegate?.shareButtonPressed(page!)
    }
    
    func topicButtonPressed() {
        delegate?.topicButtonPressed(page!)
    }
}
