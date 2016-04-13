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
    
    var cardView: CellCardView!
    var imageView = UIImageView()
    let dateFormatter = NSDateFormatter()
    var page: Page! {
        didSet {
            imageView.image = page.image
            cardView.titleLabel!.text = dateFormatter.stringFromDate(page.date!)
            cardView.detailViewLabel.text = page.name
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
        imageView.grid.rows = 6
        cardView.grid.rows = 6
        contentView.grid.axis.direction = .Vertical
        contentView.grid.views = [imageView, cardView]
        
        MaterialLayout.alignToParentHorizontally(contentView, child: cardView, left: 20, right: 20)
        MaterialLayout.alignFromBottom(contentView, child: cardView, bottom: 20)
        cardView.share.frame = CGRectMake(cardView.frame.width - 70, 10, 60, 40)

    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func setupCardView() {
        cardView = CellCardView(frame: CGRectMake(10, 10, 10, 10))
        cardView.page = page
        contentView.addSubview(cardView)
    }
    
    func setupImageView() {
        imageView.contentMode = .Center
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = MaterialColor.grey.lighten1
        contentView.addSubview(imageView)
    }
    
}
