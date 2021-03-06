//
//  TopicCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material

class TopicCollectionViewCell: UICollectionViewCell {
    
    let topicLabel: UILabel = UILabel()
    var topic: Topic?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupTitleLabel()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupTitleLabel()
    }
    
    func setupBackground() {
        //backgroundColor = MaterialColor.grey.darken1
    }
    
    func setupTitleLabel() {
        topicLabel.textColor = UIColor.whiteColor()
        topicLabel.font = RobotoFont.lightWithSize(18)
        addSubview(topicLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTitleLabel()
    }
    
    func layoutTitleLabel() {
        topicLabel.frame = CGRect(x: 20, y: 10, width: bounds.width - 40, height: bounds.height - 20)
    }
    
    func configureCell(topic: Topic) {
        self.topic = topic
        topicLabel.text = topic.name
    }
    
    
}
