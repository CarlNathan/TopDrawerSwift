//
//  CellCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/7/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material

protocol CellCardViewDelegate {
    func handleCatagoryButton(page: Page)
    func handleDeleteButton(page: Page)
    func handleShareButton(page: Page)
}
class CellCardView: CardView {
    
    let detailViewLabel = UILabel()
    var cardDelegate: CellCardViewDelegate?
    var page: Page!
    var share: FabButton!
    
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
        
        //deleteButton
        let delete = FlatButton()
        let deleteImage = UIImage(named: "ic_close_white")!.imageWithRenderingMode(.AlwaysTemplate)
        delete.setImage(deleteImage, forState: .Normal)
        delete.backgroundColor = MaterialColor.clear
        delete.pulseColor = MaterialColor.red.base
        delete.tintColor = MaterialColor.red.base
        delete.addTarget(self, action: #selector(handleDelete), forControlEvents: .TouchUpInside)
        //catagoryButton
        let catagorize = FlatButton()
        let catagorizeImage = UIImage(named: "cm_menu_white")!.imageWithRenderingMode(.AlwaysTemplate)
        catagorize.setImage(catagorizeImage, forState: .Normal)
        catagorize.pulseColor = MaterialColor.black
        catagorize.tintColor = MaterialColor.black
        catagorize.addTarget(self, action: #selector(handleCatagory), forControlEvents: .TouchUpInside)
        rightButtons = [catagorize]
        
        
        detailViewInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 20)
        titleLabelInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 20)
        leftButtonsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButtonsInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //share button
        share = FabButton(frame: CGRect.zero)
        let shareImage = UIImage(named: "cm_more_vert_white")!.imageWithRenderingMode(.AlwaysTemplate)
        share.setImage(shareImage, forState: .Normal)
        share.pulseColor = MaterialColor.white
        share.tintColor = MaterialColor.white
        share.borderColor = MaterialColor.black
        share.backgroundColor = MaterialColor.black
        share.addTarget(self, action: #selector(handleShare), forControlEvents: .TouchUpInside)
        self.addSubview(share)
        leftButtons = [delete, catagorize, share]

        
        
        
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