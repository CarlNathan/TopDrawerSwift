//
//  TopicCollectionViewCell.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/23/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit
import Material

protocol TopicCollectionViewCellDelegate {
    func deleteButtonPressed(topic: Topic)
}

class TopicCollectionViewCell: MaterialCollectionViewCell {
    
    let topicLabel: UILabel = UILabel()
    let deleteButton: UIButton = UIButton()
    var cellDelegate: TopicCollectionViewCellDelegate!
    var editEnabled: Bool = false {
        didSet {
            if editEnabled {
                deleteButton.hidden = false
            } else {
                deleteButton.hidden = true
            }
        }
    }
    var topic: Topic?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
        setupTitleLabel()
        setupDeleteButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBackground()
        setupTitleLabel()
    }
    
    func setupBackground() {
        backgroundColor = MaterialColor.grey.darken2.colorWithAlphaComponent(0.3)
    }
    
    func setupTitleLabel() {
        topicLabel.textColor = UIColor.whiteColor()
        topicLabel.font = RobotoFont.lightWithSize(18)
        addSubview(topicLabel)
    }
    
    func setupDeleteButton() {
        deleteButton.setImage(UIImage(named: "Delete Filled-100")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        deleteButton.tintColor = UIColor.whiteColor()
        deleteButton.addTarget(self, action: #selector(deleteButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(deleteButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutTitleLabel()
        layoutDeleteButton()
    }
    
    func layoutTitleLabel() {
        topicLabel.frame = CGRect(x: 25, y: 10, width: bounds.width - 45, height: bounds.height - 20)
    }
    
    func layoutDeleteButton() {
        deleteButton.frame = CGRect(x: bounds.width - bounds.height + 15, y: 15, width: bounds.height - 30, height: bounds.height - 30)
    }
    
    func configureCell(topic: Topic) {
        self.topic = topic
        topicLabel.text = topic.name
        backgroundColor = MaterialColor.grey.darken2.colorWithAlphaComponent(0.3)
    }
    
    func deleteButtonPressed() {
        if let t = topic {
            cellDelegate.deleteButtonPressed(t)
        }
    }
    
    
}
