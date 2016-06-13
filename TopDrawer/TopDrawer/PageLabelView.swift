//
//  PageLabelView.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/10/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material


protocol PageLabelViewDelegate {
    func shareButtonPressed(page: Page)
    func deleteButtonPressed(page: Page)
    func openButtonPressed(page: Page)
    func catagoryButtonPressed(page: Page)
}

class PageLabelView: UIView {
    
    var page: Page! {
        didSet {
            if let title = page?.name {
                titleLabel.text = title
            }
        }
    }
    var delegate: PageLabelViewDelegate!
    let titleLabel = UILabel()
    let dateLabel = UILabel()
    let hostNameLabel = UILabel()
    let shareButton = FlatButton()
    let deleteButton = FlatButton()
    let openButton = FabButton()
    let catagoryButton = FlatButton()
    let userImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTitleLabel()
        setupDateLabel()
        setupHostNameLabel()
        setupShareButton()
        setupDeleteButton()
        setupOpenButton()
        setupCatagoryButton()
        setupUserImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTitleLabel(){
        titleLabel.text = "The Title of the Page"
        titleLabel.textColor = MaterialColor.grey.darken3
        titleLabel.font = RobotoFont.lightWithSize(18)
        titleLabel.numberOfLines = 3
        addSubview(titleLabel)
        
    }
    
    func setupDateLabel(){
        dateLabel.text = "00/00/0000"
        dateLabel.font = RobotoFont.lightWithSize(10)
        dateLabel.textColor = MaterialColor.grey.base
        addSubview(dateLabel)
    }
    
    func setupHostNameLabel(){
        hostNameLabel.text = "whatever.com"
        hostNameLabel.font = RobotoFont.lightWithSize(12)
        hostNameLabel.textColor = MaterialColor.red.darken3
        addSubview(hostNameLabel)
    }
    
    func setupShareButton(){
        shareButton.backgroundColor = MaterialColor.white
        shareButton.imageView?.contentMode = .ScaleToFill
        shareButton.setImage(UIImage(named:"ic_more_horiz_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        shareButton.tintColor = MaterialColor.black
        shareButton.addTarget(self, action: #selector(handleShareButton), forControlEvents: .TouchUpInside)
        addSubview(shareButton)
    }
    
    func setupDeleteButton(){
        deleteButton.tintColor = MaterialColor.red.darken1
        deleteButton.addTarget(self, action: #selector(handleDeleteButton), forControlEvents: .TouchUpInside)
        deleteButton.setImage(UIImage(named:"ic_close_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        addSubview(deleteButton)
    }
    
    func setupOpenButton(){
        openButton.backgroundColor = MaterialColor.white
        openButton.borderColor = MaterialColor.black
        openButton.setImage(UIImage(named: "ic_share_white")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        openButton.addTarget(self, action: #selector(handleOpenButton), forControlEvents: .TouchUpInside)
        addSubview(openButton)
    }
    
    func setupCatagoryButton(){
        catagoryButton.backgroundColor = MaterialColor.black
        catagoryButton.addTarget(self, action: #selector(handleCatagoryButton), forControlEvents: .TouchUpInside)
        addSubview(catagoryButton)
    }
    
    func setupUserImage(){
        userImage.image = UIImage(named:"contacts")
        userImage.contentMode = .ScaleToFill
        addSubview(userImage)
    }
    
    override func layoutSubviews() {
        layoutDateLabel()
        layoutTitleLabel()
        layoutHostNameLabel()
        layoutDeleteButton()
        layoutShareButton()
        layoutOpenButton()
        //layoutCatagoryButton()
        layoutUserImage()
    }
    
    func layoutTitleLabel(){
        titleLabel.frame = CGRect(x: (bounds.width*(1/10)), y: (dateLabel.frame.maxY), width: (bounds.width - (bounds.width/10)), height: 10)
        titleLabel.sizeToFit()
    }
    
    func layoutHostNameLabel(){
        hostNameLabel.frame = CGRect(x: (bounds.width*(1/10)), y: (titleLabel.frame.maxY), width: (bounds.width - (bounds.width)*(2/10)), height: 10)
        hostNameLabel.sizeToFit()
    }
    
    func layoutDateLabel(){
        dateLabel.frame = CGRect(x: (bounds.width*(1/10)), y: (bounds.height*(2/10)), width: (bounds.width - (bounds.width/10)), height: 10)
        dateLabel.sizeToFit()
    }
    
    func layoutDeleteButton(){
        deleteButton.frame = CGRect(x: 10, y: bounds.height - 40, width: (bounds.width-40)/3, height: 30)
    }
    
    func layoutShareButton(){
        shareButton.frame = CGRect(x: deleteButton.frame.maxX + 10, y: bounds.height - 40, width: (bounds.width-40)/3, height: 30)
    }
    
    
    func layoutOpenButton(){
        openButton.frame = CGRect(x: shareButton.frame.maxX + 10, y: bounds.height - 40, width: (bounds.width-40)/3, height: 30)
    }
    
    func layoutCatagoryButton(){
        catagoryButton.frame = CGRect(x: (bounds.width*(1/10)), y: dateLabel.frame.maxY + 5, width: (bounds.width - (bounds.width/10)), height: 20)
    }
    
    func layoutUserImage(){
        userImage.frame = CGRect(x: bounds.width - 40, y: 10, width: 20, height: 20)
    }
    
    func handleShareButton(){
        delegate.shareButtonPressed(page)
    }
    
    func handleDeleteButton(){
        delegate.deleteButtonPressed(page)
    }
    
    func handleOpenButton(){
        delegate.openButtonPressed(page)
    }
    
    func handleCatagoryButton(){
        delegate.catagoryButtonPressed(page)
    }

}