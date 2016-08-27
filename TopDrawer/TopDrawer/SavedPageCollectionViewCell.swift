//
//  SavedPageCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material


class SavedPageCollectionViewCell: MaterialCollectionViewCell {
    
    var labelView: PageLabelView!
    var imageView = UIImageView()
    let dateFormatter = NSDateFormatter()
    var page: Page! {
        didSet {
            imageView.image = page.image
            labelView.dateLabel.text = dateFormatter.stringFromDate(page.date!)
            labelView.page = page
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupLabelView()
        borderColor = MaterialColor.blue.base
        backgroundColor = MaterialColor.white
        dateFormatter.dateFormat = "MM/dd/yyyy"
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabelView()
        setupImageView()
        backgroundColor = MaterialColor.white
        depth = .Depth2
        masksToBounds = false
        dateFormatter.dateFormat = "MM/dd/yyyy"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.contentView.frame = self.bounds;
        imageView.grid.columns = 5
        labelView.grid.columns = 7
        contentView.grid.axis.direction = .Horizontal
        contentView.grid.views = [imageView, labelView]
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func setupLabelView() {
        labelView = PageLabelView(frame: CGRect.zero)
        labelView.page = page
        contentView.addSubview(labelView)
    }
    
    func setupImageView() {
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = MaterialColor.grey.lighten1
        contentView.addSubview(imageView)
    }
    
}
