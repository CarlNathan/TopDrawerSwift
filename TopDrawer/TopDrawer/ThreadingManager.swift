//
//  ThreadingManager.swift
//  TopDrawer
//
//  Created by Carl Udren on 6/22/16.
//  Copyright © 2016 Carl Udren. All rights reserved.
//

import Foundation

class ThreadingManager {
    
    func runInBackgroundThread(block: ()->Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            block()
        }
    }
    
    func runInMainThread(block: ()->Void) {
        dispatch_async(dispatch_get_main_queue()) { 
            block()
        }
    }

}
