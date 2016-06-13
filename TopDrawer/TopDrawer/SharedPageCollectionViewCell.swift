//
//  SharedPageCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/27/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material

class SharedPageCollectionViewCell: MaterialCollectionViewCell {
    
    var cardView: PageLabelView!
    var imageView = UIImageView()
    let dateFormatter = NSDateFormatter()
    var page: Page! {
        didSet {
            imageView.image = page.image
            cardView.dateLabel.text = dateFormatter.stringFromDate(page.date!)
            cardView.titleLabel.text = page.name
            cardView.page = page
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupCardView()
        borderColor = MaterialColor.blue.base
        backgroundColor = MaterialColor.white
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCardView()
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
        cardView.grid.columns = 7
        contentView.grid.axis.direction = .Horizontal
        contentView.grid.views = [imageView, cardView]
        
        MaterialLayout.alignToParentHorizontally(contentView, child: cardView, left: 20, right: 20)
        MaterialLayout.alignFromBottom(contentView, child: cardView, bottom: 20)
        
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func setupCardView() {
        cardView = PageLabelView(frame: CGRect.zero)
        cardView.page = page
        contentView.addSubview(cardView)
    }
    
    func setupImageView() {
        imageView.contentMode = .ScaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = MaterialColor.grey.lighten1
        contentView.addSubview(imageView)
    }

    
}
