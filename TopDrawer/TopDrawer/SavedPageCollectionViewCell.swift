//
//  SavedPageCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material

class SavedPageCollectionViewCell: UICollectionViewCell {
    
    var cardView: CardView!
    var imageView = MaterialPulseView()
    var page: Page! {
        didSet {
            imageView.image = page.image
            cardView.titleLabel!.text = page.name
        }
    }
    
    
    override func init() {
        self.frame = frame
        setupCardView()
    }
    override func layoutSubviews() {
        contentView.grid
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
    
    func setupCardView() {
        cardView = CardView(frame: <#T##CGRect#>)
    }
    
    func setupImageView() {
        contentView.addSubview(imageView)
    }
}
