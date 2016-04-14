//
//  TopicTableCardView.swift
//  TopDrawer
//
//  Created by Carl Udren on 4/13/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import Material
import UIKit

class NewTopicPopupVC: UIViewController {
    //
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalTransitionStyle = .CoverVertical
        modalPresentationStyle = .PageSheet
        
    }
    
    convenience init() {
        self.init()
    }
    
    class func presentPopupCV(sender: UIViewController, view: UIView) {
        sender.navigationController?.definesPresentationContext = true
        let popup = NewTopicPopupVC()
        sender.presentViewController(popup, animated: true) {
            //completion
        }
    }

}
