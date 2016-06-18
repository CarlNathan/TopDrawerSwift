//
//  Friend.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/26/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation
import UIKit

class Friend {
    var firstName: String?
    var familyName: String?
    var recordID: String!
    var userImage: UIImage?
    var email: String?
    
    init (firstName: String?, familyName: String?, recordIDString: String, image: UIImage?) {
        self.firstName = firstName
        self.familyName = familyName
        self.recordID = recordIDString
        self.userImage = image
    }
}