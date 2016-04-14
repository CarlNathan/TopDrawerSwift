//
//  SharedTopicCellCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit
import Material

class SharedTopicCellCardView: CardView {
    
    let detailViewLabel = UILabel()
    var cardDelegate: CellCardViewDelegate?
    var page: Page!
    var share: FlatButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label = UILabel()
        label.textColor = MaterialColor.grey.base
        label.font = RobotoFont.lightWithSize(12)
        titleLabel = label
        detailViewLabel.numberOfLines = 2
        detailViewLabel.font = RobotoFont.lightWithSize(16)
        detailView = detailViewLabel
        divider = false
        cornerRadius = 0
        
        //catagoryButton
        let catagorize = FlatButton()
        let catagorizeImage = UIImage(named: "cm_menu_white")!.imageWithRenderingMode(.AlwaysTemplate)
        catagorize.setImage(catagorizeImage, forState: .Normal)
        catagorize.pulseColor = MaterialColor.black
        catagorize.tintColor = MaterialColor.black
        catagorize.addTarget(self, action: #selector(handleCatagory), forControlEvents: .TouchUpInside)
        leftButtons = [catagorize]
        
        
        detailViewInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        titleLabelInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 20)
        leftButtonsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButtonsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //share button
        share = FlatButton(frame: CGRectMake(0,0,0,0))
        let shareImage = UIImage(named: "cm_more_vert_white")!.imageWithRenderingMode(.AlwaysTemplate)
        share.setImage(shareImage, forState: .Normal)
        share.pulseColor = MaterialColor.black
        share.tintColor = MaterialColor.black
        share.addTarget(self, action: #selector(handleShare), forControlEvents: .TouchUpInside)
        rightButtons = [share]
        
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleDelete () {
        cardDelegate?.handleDeleteButton(page)
    }
    
    func handleShare () {
        cardDelegate?.handleShareButton(page)
    }
    
    func handleCatagory () {
        cardDelegate?.handleCatagoryButton(page)
    }
}
