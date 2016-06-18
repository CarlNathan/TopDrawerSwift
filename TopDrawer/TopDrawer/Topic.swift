//
//  Topic.swift
//  TopDrawer
//
//  Created by Carl Udren on 2/25/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import UIKit

class Topic {
    var name: String?
    var users: [Friend]?
    var recordID: String?
    
    init(){
        
    }
    
    init (name: String?, users: [Friend]?, recordID: String?){
        self.name = name
        self.users = users
        self.recordID = recordID
        
    }

}

