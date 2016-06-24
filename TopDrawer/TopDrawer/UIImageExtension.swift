//
//  UIImageExtension.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/20/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func scaleImage(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0.0)
        self.drawInRect(CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage;
    }
}
