//
//  TopicCellCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class TopicCellCardView: CellCardView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        detailViewLabel.numberOfLines = 4
        pulseScale = false
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}